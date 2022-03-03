process mipgen {

        tag "$lane"
        time { 30.minute * task.attempt }
		memory '2 GB'
        errorStrategy 'retry'
        maxRetries 3
		container = 'docker://laurenshannes/revivid'
		cpus 1

	input:
	tuple val(id), val(lane),file(assembled)
	path barcodes

	output:
	tuple val(id),val(lane),file(${lane}.indexed.fastq)

	
	$/
    python2.7 mipgen_fq_cutter_se.py $assembled -t -b $barcodes -m 8,0 -o ${lane}.temp
	sed -e 's/ /_/' ${lane}.temp* | perl -pe 's/(?<=\d):(?=[ATGCN]{8})/:#/;' > ${lane}.indexed.fastq
	/$

}