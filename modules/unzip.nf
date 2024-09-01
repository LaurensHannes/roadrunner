process unzip {


	tag "${compressed}"
	cpus 1


	
	input:
    path compressed 
	
	output:
	path '*.fastq.gz'
	
	"""
	unzip '$compressed'
	if compgen -G "*_R*.fastq.gz" >/dev/null ; then 
	for file in *_R*.fastq.gz; do mv "\$file" "\${file/_R/.R}"; done
	fi
	"""
	
	}
