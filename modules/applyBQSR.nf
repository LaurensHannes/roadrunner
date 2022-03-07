process applyBQSR {

        tag "$lane"
		 time { 30.minute * task.attempt }
		 errorStrategy 'retry' 
		maxRetries 3
		cpus 1
			container "broadinstitute/gatk"


        input:

		tuple val(id), val(lane) , file(bam), file(bai), file(table)
        path genome
		path indexes 
        path dict 


        output:
        tuple val(id), val(lane) ,file("${lane}.recallibrated.bam"),file("${lane}.recallibrated.bam.bai") 

        """
        gatk ApplyBQSR -R $genome -I $bam -bqsr-recal-file $table -O ${id}.${lane}.recallibrated.bam
		samtools index -@ ${task.cpus} ${lane}.recallibrated.bam
		
		
        """

}