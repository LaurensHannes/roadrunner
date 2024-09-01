 process alignment {


		cpus { 4 * task.attempt }

		memory { 8.GB * task.attempt }
		tag "$lane"
			 time { 4.hour * task.attempt }
		 errorStrategy 'retry' 
		maxRetries 3


		input:
        tuple val(id),val(lane),file(cutfastq)
        path genome
        path indexes


        output:
        tuple val(id), val(lane), file("${lane}.indexed.bam"), file("${lane}.indexed.bam.bai")

        """
        bwa mem -r 0.5 -t ${task.cpus} -C $genome $cutfastq | samtools sort -@ ${task.cpus} -o ${lane}.indexed.bam
		samtools index -@ ${task.cpus} ${lane}.indexed.bam
        """
}