process unzip {


	tag "${compressed}"
	cpus 1
	executor 'local'

	
	input:
    file compressed 
	
	output:
	file '*.fastq.gz'
	
	"""
unzip '$compressed'
	"""
	
	}