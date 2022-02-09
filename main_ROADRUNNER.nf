#! usr/bin/env nextflow


nextflow.enable.dsl=2

log.info """\

 R O A D R U N N E R - W G S - P I P E L I N E
 =============================================
 #############################################
 ################## DSL 2 ####################
 ################## W I P ####################
 ################## alpha ####################
 #############################################
 =============================================
 """

run = channel.value('run10')
tools =channel.fromPath(params.tools)

barcodes_ch = Channel.fromPath(params.barcodes)
R_ch = Channel.from(params.Readdirection)
zip_ch = channel.fromPath(params.rawdata)

unzip
unzip.out.flatten().filter(~/.*R\d+.fastq.gz/).map{file -> tuple(file.getBaseName(3), file)}.groupTuple().dump(tag:"test").flatten().collate( 3 ).map{lane,R1,R2 -> tuple(R1.simpleName,lane,R1,R2)}.set{gzipped_ch}
fastQC(gzipped_ch)
pear(gzipped_ch)
mipgenPE(pear.out(0),barcodes_ch)

process alignment {
	cpus 16
	input:
	file reads from mipgen_ch
	val x from run
//	file barcodes from barcodes_ch	
	path genome from params.genome
	path index from index_ch
	
	output:
	file "$x*" into mapped_ch

	"""
	bwa mem -r 0.5 -t ${task.cpus} $genome ${x}.indexed.fq | samtools view -@ ${task.cpu} -bS | samtools sort -@ ${task.cpu} -o ${x}.indexed.bam
	"""
}

process mipgenparam {
	
	input:
	val dir from tools
	val x from run
	path sortedbam from mapped_ch
	path barcodes from params.barcodes
	path mips from params.mips

	output:
	file '*' into mipgen_params_ch

	"""
	samtools view -h $sortedbam | python2.7 ${dir}/mipgen_smmip_collapser.py 8 ${x}.collapse -m $mips -f 2 -T -r -w False -S -b $barcodes -s
	"""

}

process sortbam {

	input:
	path sams from mipgen_params_ch.flatten().filter( ~/.+\.uncollapsed.sam/)

	output:
	path '*.bam' into sorted_ch

	"""
	samtools view -bS $sams | samtools sort -o ${sams}.bam
	samtools index ${sams}.bam
	"""
}


process genotype {

 	memory '6 GB'

	input:
	path bams from sorted_ch
	path genome from params.genome	
	path dict from feature_ch
	path index from index_ch	
	path faidx from faidx_ch

	output:
	path '*.vcf' into vcfs_ch

	"""
	 /usr/roadrunner/programs/gatk-4.1.8.1/gatk HaplotypeCaller --verbosity WARNING --output-mode EMIT_ALL_ACTIVE_SITES -R $genome -I ${bams} -O ${bams}.vcf --sequence-dictionary ${dict}
	"""

}
vcfs_ch.view()

