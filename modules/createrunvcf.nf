process create_run_vcf {

	publishDir "./results/$run", mode: 'copy', overwrite: true

        input:
        path vcfgz 
        path vcftbi
        val run
        val GQ 
		path alleles
		path allelesidx

        output:
        tuple val(run), val(GQ), path("${run}.${GQ}.vcf") 

        """
		bgzip $alleles
		tabix ${alleles}.gz
        vcf-merge ${alleles}.gz $vcfgz > ${run}.${GQ}.vcf
        """
}