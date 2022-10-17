process create_wise_files {

	tag "$id"

	input:
	tuple val(id), path(on), path(off)
	tuple val(id), path(onmips), path(offmips)
	path barcodes
	val run

	output:
	tuple val(id),path ("${id}.samplewise.txt")
	tuple val(id),path ("${id}.mipwise.txt")
	tuple val(id),path ("${id}.probes.txt")
	
	"""
	index=\$(echo $id | egrep -o "[ACTG]{8}")
	id=\$(egrep "\$index" $barcodes | cut -f 1)
	paste <(tail -n 1 $on | cut -f 1,3) <(cut -d "," -f 2 $off)  > ${id}.samplewise.txt
	cat <(echo "\$id""_on""\t""\$id""_off") <(paste <(tail -n "\$((\$(wc -l $onmips | cut -f 1 -d ' ')-1))" $onmips | sort -k2,2 | cut -f 3 ) <(sort -k1,1 $offmips | cut -f 2))  > ${id}.mipwise.txt
	cat <(echo "mip_probe") <(sort -k1,1 $offmips | cut -f 1) > ${id}.probes.txt	
"""

}