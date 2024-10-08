process prepare_interval {

	input:
	path design

	output:
	file("interval.bed")
	
	"""
	paste <(cat <(cat <(cat $design | egrep '^[0-9]{1,2}' | sort -n -k1 -k2) <(cat $design | egrep '^[X,Y]' | sort -n -k2)) | cut -f 1) <(cat <(cat <(cat $design | egrep '^[0-9]{1,2}' | sort -n -k1 -k2) <(cat $design | egrep '^[X,Y]' | sort -n -k2)) | cut -f 2 | awk '{\$1 = \$1 - 250; print}') <(cat <(cat <(cat $design | egrep '^[0-9]{1,2}' | sort -n -k1 -k2) <(cat $design | egrep '^[X,Y]' | sort -n -k2)) | cut -f 2 | awk '{\$1 = \$1 + 250; print}') > interval.bed

	"""
}
