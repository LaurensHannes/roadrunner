process mipgenparam {

        tag "$lane"
        time { 30.minute * task.attempt }
		memory '2 GB'
        errorStrategy 'retry'
        maxRetries 3
		container = 'docker://laurenshannes/revivid'
		cpus 1
		
        input:

	    tuple val(id), val(lane), file(bam)
        path barcodes
        path mips

        output:
    
	tuple val(id), val(lane), path('*.uncollapsed.sam')
	tuple val(id), val(lane), path('*.off_target_reads.sam')
	tuple val(id), val(lane), path('*samplewise*')
	tuple val(id), val(lane), path('*mipwise*')
	tuple val(id), val(lane), path('*')

	"""
	echo "${id}" | egrep -o '[ACGT]{8}' > temp.txt
	fgrep -f temp.txt $barcodes > bc.txt 
    samtools view -h $bam | python2.7 /usr/roadrunner/programs/MIPGEN/tools/mipgen_smmip_collapser.py 8 ${lane} -m $mips -f 2 -T -r -w False -S -b bc.txt -s
	"""	

}