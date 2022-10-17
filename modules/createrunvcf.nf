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
        path '${run}.${GQ}.vcf' into run_vcf_ch

        """
        vcf-merge $vcfgz > ${run}.${GQ}.vcf
        """
}