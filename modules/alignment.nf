 process alignment {


		cpus { 4 * task.attempt }

		memory { 8.GB * task.attempt }
		tag "$lane"
			 time { 4.hour * task.attempt }
		 errorStrategy 'retry' 
		maxRetries 3


		input:
        tuple val(id), val(lane),file(R1), file(R2)
        path genome
        path indexes


        output:
        tuple val(id), val(lane), file("${lane}.indexed.bam")

        """
        bwa mem -t ${task.cpus} $genome $R1 $R2 | samtools sort -@ ${task.cpus} -o ${lane}.indexed.bam
        """
}