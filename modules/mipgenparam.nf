process mipgenparam {

        tag "$id"
        time { 30.minute * task.attempt }
		memory '2 GB'
        errorStrategy 'retry'
        maxRetries 3
		cpus 1
		
        input:

	    tuple val(id), file(bam), file(bai)
        path barcodes
        path mips

        output:
    
	tuple val(id), path('*.uncollapsed.sam')
	tuple val(id), path('*.off_target_reads.sam')
	tuple val(id), path('*samplewise*')
	tuple val(id), path('*mipwise*')
	tuple val(id), path('*')

	"""
	echo "${id}" | egrep -o '[ACGT]{8}' > temp.txt
	fgrep -f temp.txt $barcodes > bc.txt 
    samtools view -h $bam | python2.7 /usr/roadrunner/programs/MIPGEN/tools/mipgen_smmip_collapser.py 8 ${id} -m $mips -f 2 -T -r -w False -S -b bc.txt -s
	"""	

}