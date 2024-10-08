process duplicates { 

        tag "$id"
		
		container "docker://broadinstitute/gatk"
        errorStrategy 'retry'
         maxRetries 3
		 	maxForks 32
			
		
	input:
	tuple val(id),file(bam),file(bai) 


	output:
	tuple val(id),file("${id}.dups.bam"),file("${id}.dups.bam.bai")
	tuple val(id),file("${id}.metrics.txt")

	
	"""
	gatk MarkDuplicates -I $bam -O ${id}.dups.bam -M ${id}.metrics.txt -DS RANDOM
	samtools index ${id}.dups.bam
	"""
}
