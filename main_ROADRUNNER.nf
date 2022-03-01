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

process GQfilter {

        input:
        val GQ from GQ_ch
        path vcf from vcfs_ch

        output:
        path '*.vcf' into vcf_GQ_ch

        """
        /usr/roadrunner/programs/gatk-4.1.8.1/gatk FilterVcf -I $vcf --MIN_GQ $GQ -O ${vcf.baseName}.${GQ}.vcf
        """

}

process gzvcf {

        input:
        path vcf from vcf_GQ_ch

        output:
        path '*.vcf.gz' into vcfgz_ch
	path '*.vcf.gz.tbi' into vcfgztbi_ch
        """
        bgzip $vcf
        tabix -p vcf ${vcf}.gz
        """

}


process create_run_vcf {

	publishDir "${dir}"

        input:
        path vcfgz from vcfgz_ch.flatten().toList()
        path vcftbi from vcfgztbi_ch.flatten().toList()
        val x from run
        val GQ from GQ_ch
	  val dir from output

        output:
        path '*.vcf' into run_vcf_ch

        """
        vcf-merge $vcfgz > ${x}.${GQ}.vcf
        """
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


process prepare_offtarget {

	tag "$x"

        input:
        path mips from params.mips
        tuple val(x), file(sam) from mipgen_offtarget

        output:
        tuple val(x), path('*.reversedcomplement.txt'), path('*.extension.txt'),path('*.samples.offtarget.sam'),path('*.mips.offtarget.sam') into offtargetfiles_ch	


        """
        cat $mips | uniq -f 7 | cut -f 7 | sed '1d' | perl -ple 'y/ACGT/TGCA/ and \$_ = reverse unless /^>/' | sort -u > ${x}.reversedcomplement.txt
        cat $mips | cut -f 1,7 | sed '1d' | sort -u -k2,2 > ${x}.extension.txt
        cat $sam | cut -f 1 > ${x}.samples.offtarget.sam
        cat $sam | cut -f 10 > ${x}.mips.offtarget.sam
        """

}

process offtargetcount {
	
	tag "$x"	

        input:
        tuple val(x), path(rc), path(ext), path(samples), path(mips) from offtargetfiles_ch
        path barcodes from params.barcodes
        

        output:
        tuple val(x), path('*samples.csv') into offtsamples_ch
	tuple val(x), path('*mips.csv') into offtmips_ch	

        """
        echo "$x" | egrep -o '[ACGT]{8}' > temp.txt
        fgrep -f temp.txt $barcodes > bc.txt
        python3 /usr/roadrunner/scripts/offtargetsamples.py -E bc.txt -OFF $samples -OUT ${x}.samples
        python3 /usr/roadrunner/scripts/offtargetmips.py -E $ext -R $rc -OFF $mips -OUT ${x}.mips.temp
	sed -i -e 's/\"//g' ${x}.mips.temp.csv
	perl -pe 's/(?<=[+-]),(?=[0123456789]+)/\t/g' ${x}.mips.temp.csv > ${x}.mips.temp2.csv
	awk '{a[\$1]+=\$2}END{for(i in a) print i,a[i]}' ${x}.mips.temp2.csv > ${x}.mips.csv
        sed -i -e 's/\\s/\\t/g' ${x}.mips.csv
	"""
}

mipgen_offtarget_stats.into { mipgen_offtarget_mips_stats; mipgen_offtarget_samples_stats}

mipgen_samplewise_ch.join(offtsamples_ch).set{joined_samples_ch}
mipgen_mipwise_ch.join(offtmips_ch).set{joined_mips_ch}

process create_wise_files {

publishDir "${dir}"

	input:
	tuple val(x), path(on), path(off) from joined_samples_ch
	tuple val(x), path(onmips), path(offmips) from joined_mips_ch
	path barcodes from params.barcodes
	  val dir from output


	output:
	path ('*.samplewise.txt') into samplewise_ch
	path ('*.mipwise.txt') into mipwise_ch
	path ('probes.txt') into probes_ch
	"""
	index=\$(echo $x | egrep -o "[ACTG]{8}")
	id=\$(egrep "\$index" $barcodes | cut -f 1)
	paste <(tail -n 1 $on | cut -f 1,3) <(cut -d "," -f 2 $off)  > "\$id".samplewise.txt
	cat <(echo "\$id""_on""\t""\$id""_off") <(paste <(tail -n "\$((\$(wc -l $onmips | cut -f 1 -d ' ')-1))" $onmips | sort -k2,2 | cut -f 3 ) <(sort -k1,1 $offmips | cut -f 2))  > "\$id".mipwise.txt
	cat <(echo "mip_probe") <(sort -k1,1 $offmips | cut -f 1) > probes.txt	
"""

}

//samplewise_ch.toList().view()

process combined_wise {
	
	input: 
	path(samples) from samplewise_ch.flatten().toList()
	path(mips) from mipwise_ch.flatten().toList()
	path(probes) from probes_ch.first()
	val x from run

	output:
	path ("*.samplewise_combined.txt") into samplewisecombined_ch
	path ("*.mipwise_combined.txt") into mipwisecombined_ch

	"""
	cat <(echo "sample""\t""on""\t""off") $samples > ${x}.samplewise_combined.txt
	paste  $probes $mips > ${x}.mipwise_combined.txt
	"""

}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

process table {

        tag "$x"
        publishDir "${dir}"

        input:
        val x from run
        file vcf from run_vcf_ch
        val dir from output

        output:
        path("${x}.genotypes.tsv") into table_ch


        """
        plink1.9 --vcf $vcf --allow-no-sex --recode --out table --make-bed

        transpose -t -l 2000x2000 --fsep " " table.ped > table.transposed.ped
head -n 1 table.transposed.ped > header.transposed.ped
sed -i '1,6d' table.transposed.ped
rm table.ped
transpose -t -l 2000x2000 --fsep " " table.transposed.ped > table.ped
sed -i "s/[^ ]\$/& /;s/ \\([^ ]*\\) /\\|\\1 /g" table.ped
rm table.transposed.ped
transpose -t -l 2000x2000 --fsep " " table.ped > table.transposed.ped
cat header.transposed.ped table.transposed.ped > table_cut.ped
sed -i -e 's/ /\\t/g' table_cut.ped

cat table.map | cut -f 1,2,4 > table_cut.map
sed -i -e '1s/^/chr\\tid\\tpos\\n/' table_cut.map

paste table_cut.map table_cut.ped > ${x}.genotypes.tsv

"""

}