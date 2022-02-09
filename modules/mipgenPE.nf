process mipgen {

        tag "$lane"
        time { 30.minute * task.attempt }
		memory '2 GB'
        errorStrategy 'retry'
        maxRetries 3
		container = 'docker://laurenshannes/revivid'
		cpus { 8 * task.attempt }

	input:
	tuple val(id), val(lane),file(assembled)
	path barcodes from params.barcodes

	output:
	file "$x*"

	"""	
	python2.7  /usr/roadrunner/programs/MIPGEN/tools/mipgen_fq_cutter_se.py $assembled -t -b $barcodes -m 8,8 -o $lane
	"""
}