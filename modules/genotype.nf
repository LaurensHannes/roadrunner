process genotype {

        tag "$id"
		 time { 12.hour * task.attempt }
		 errorStrategy 'retry' 
		maxRetries 3
		container "broadinstitute/gatk"
		
	memory { 4.GB * task.attempt }
	cpus 1
		myDir = file('./results/vcfs')
	myDir.mkdirs()
	publishDir './results/vcfs', mode: 'copy', overwrite: true




        input:
        tuple val(id), file(bam),file(bai) 
        path genome 
        path indexes
		path interval
		path dict	
		path alleles
		path allelesidx

	output:		
      
        tuple val(id), file("${id}.vcf.gz"), file("${id}.vcf.gz.tbi")
	tuple val(id), file("${id}.haplotypecaller.bam")
        """
        gatk HaplotypeCaller --verbosity INFO -L $interval -R $genome -I $bam -O ${id}.temp.vcf.gz --sequence-dictionary ${dict} --native-pair-hmm-threads ${task.cpus} --force-call-filtered-alleles true --alleles $alleles --dbsnp $alleles --mapping-quality-threshold-for-genotyping 0  --minimum-mapping-quality 0 --force-active true -ERC  BP_RESOLUTION --max-reads-per-alignment-start 0 -bamout ${id}.haplotypecaller.bam --all-site-pls true --output-mode EMIT_ALL_ACTIVE_SITES
		gatk SelectVariants -R $genome -V ${id}.temp.vcf.gz -O ${id}.temp2.vcf.gz --concordance $alleles  
		gatk LeftAlignAndTrimVariants -R $genome -V ${id}.temp2.vcf.gz -O ${id}.vcf.gz
        """

}
