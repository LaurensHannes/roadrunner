process create_run_vcf {

	myDir = file('./results/$run')
	myDir.mkdirs()
	publishDir './results/$run', mode: 'copy', overwrite: true

        input:
        path vcfgz 
        path vcftbi
        val run
        val GQ 

        output:
        tuple val(run), val(GQ), path("${run}.${GQ}.vcf") 

        """
        vcf-merge $vcfgz > ${run}.${GQ}.vcf
        """
}