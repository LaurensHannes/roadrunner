process pear {



        tag "$lane"
        time { 8.hour * task.attempt }
		memory '2 GB'
        errorStrategy 'retry'
        maxRetries 3
		container = 'docker://laurenshannes/revivid'
		cpus { 8 * task.attempt }
		
        input:
        tuple val(id), val(lane),file(R1), file(R2)
		path home
		
        output:
        tuple val(id), val(lane), file("${lane}.assembled.fastq")
        tuple val(id), val(lane), file("${lane}.unassembled.forward.fastq")
        tuple val(id), val(lane), file("${lane}.unassembled.reverse.fastq")

		"""
		pear -j ${task.cpus} -f $R1 -r $R2 -o $lane
		"""
		}