process genotype {

        tag "$lane"
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
        tuple val(id), val(lane), file(bam),file(bai) 
        path genome 
        path indexes
		path interval
		path dict		

		
		
        output:
        tuple val(id), file("${lane}.g.vcf.gz")
        """
        gatk HaplotypeCaller --verbosity INFO -ERC GVCF -L $interval -R $genome -I $bam -O ${lane}.g.vcf.gz --sequence-dictionary ${dict} --pcr-indel-model NONE -G StandardAnnotation -G AS_StandardAnnotation -G StandardHCAnnotation --native-pair-hmm-threads ${task.cpus}
        """

}