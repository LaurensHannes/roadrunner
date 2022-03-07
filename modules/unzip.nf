process unzip {


	tag "${compressed}"
	cpus 1


	
	input:
    path compressed 
	
	output:
	path '*.fastq.gz'
	
	"""
	unzip '$compressed'
	"""
	
	}