process pear {



        tag "$lane"
        time { 8.hour * task.attempt }

        errorStrategy 'retry'
        maxRetries 3


		
        input:
        tuple val(id), val(lane),file(R1), file(R2)

		
        output:
        tuple val(id), val(lane), file("${lane}.assembled.fastq")
        tuple val(id), val(lane), file("${lane}.unassembled.forward.fastq")
        tuple val(id), val(lane), file("${lane}.unassembled.reverse.fastq")

		"""
		pear -j ${task.cpus} -f $R1 -r $R2 -o $lane
		"""
		}