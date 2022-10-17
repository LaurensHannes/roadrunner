process offtargetcount {

	tag "$id"

        input:
        
        tuple val(id), file(sam)
		path mips
		path barcodes
		

		output:
		tuple val(id), path("${id}.samples.csv")
		tuple val(id), path("${id}.mips.csv")
	

		"""
		cat $mips | uniq -f 7 | cut -f 7 | sed '1d' | perl -ple 'y/ACGT/TGCA/ and \$_ = reverse unless /^>/' | sort -u > ${id}.reversedcomplement.txt
		cat $mips | cut -f 1,7 | sed '1d' | sort -u -k2,2 > ${id}.extension.txt
		cat $sam | cut -f 1 > ${id}.samples.offtarget.sam
		cat $sam | cut -f 10 > ${id}.mips.offtarget.sam
		
		echo "$id" | egrep -o '[ACGT]{8}' > temp.txt
		fgrep -f temp.txt $barcodes > bc.txt
		python3 /usr/roadrunner/scripts/offtargetsamples.py -E bc.txt -OFF ${id}.samples.offtarget.sam -OUT ${id}.samples
		python3 /usr/roadrunner/scripts/offtargetmips.py -E ${id}.extension.txt -R ${id}.reversedcomplement.txt -OFF ${id}.mips.offtarget.sam -OUT ${id}.mips.temp
		sed -i -e 's/\"//g' ${id}.mips.temp.csv
		perl -pe 's/(?<=[+-]),(?=[0123456789]+)/\t/g' ${id}.mips.temp.csv > ${id}.mips.temp2.csv
		awk '{a[\$1]+=\$2}END{for(i in a) print i,a[i]}' ${id}.mips.temp2.csv > ${id}.mips.csv
		sed -i -e 's/\\s/\\t/g' ${id}.mips.csv
		"""


}



