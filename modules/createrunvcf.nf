process create_run_vcf {

	container "docker://nanozoo/bcftools:1.19--1dccf69"
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
        bcftools merge -m both,** ${alleles}.gz $vcfgz > ${run}.temp.${GQ}.vcf
	 bcftools plugin setGT -- ${run}.temp.${GQ}.vcf -t q -n ./. -i 'FMT/DP<20 && GQ<20' > ${run}.${GQ}.vcf
        #vcf-merge $vcfgz > ${run}.${GQ}.vcf
	"""
}
