process genotype {

        tag "$id"
		 time { 12.hour * task.attempt }
		 errorStrategy 'retry' 
		maxRetries 3
		container "docker://broadinstitute/gatk"
	memory { 4.GB * task.attempt }
	cpus 1
		myDir = file('./results/vcfs')
	myDir.mkdirs()
	publishDir './results/vcfs', mode: 'copy', overwrite: false




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
        """
        gatk HaplotypeCaller --verbosity INFO -L $interval -R $genome -I $bam -O ${id}.vcf.gz --sequence-dictionary ${dict} --native-pair-hmm-threads ${task.cpus} --force-call-filtered-alleles true --alleles $alleles 
        """

}