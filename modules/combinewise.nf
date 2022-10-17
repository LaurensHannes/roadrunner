process combined_wise {
	
		tag "$id"
		publishDir "./results/$run", mode: 'copy', overwrite: true
	
	input: 
	path(samples)
	path(mips)
	path(probes)
	val run 
	
	output:
	tuple val(run),path ("${run}.samplewise_combined.txt")
	tuple val(run),path ("${run}.mipwise_combined.txt")

	"""
	cat <(echo "sample""\t""on""\t""off") $samples > ${run}.samplewise_combined.txt
	paste  $probes $mips > ${run}.mipwise_combined.txt
	"""

}