process create_wise_files {

publishDir "${dir}"

	input:
	tuple val(x), path(on), path(off) from joined_samples_ch
	tuple val(x), path(onmips), path(offmips) from joined_mips_ch
	path barcodes from params.barcodes
	  val dir from output


	output:
	path ('*.samplewise.txt') into samplewise_ch
	path ('*.mipwise.txt') into mipwise_ch
	path ('probes.txt') into probes_ch
	"""
	index=\$(echo $x | egrep -o "[ACTG]{8}")
	id=\$(egrep "\$index" $barcodes | cut -f 1)
	paste <(tail -n 1 $on | cut -f 1,3) <(cut -d "," -f 2 $off)  > "\$id".samplewise.txt
	cat <(echo "\$id""_on""\t""\$id""_off") <(paste <(tail -n "\$((\$(wc -l $onmips | cut -f 1 -d ' ')-1))" $onmips | sort -k2,2 | cut -f 3 ) <(sort -k1,1 $offmips | cut -f 2))  > "\$id".mipwise.txt
	cat <(echo "mip_probe") <(sort -k1,1 $offmips | cut -f 1) > probes.txt	
"""

}