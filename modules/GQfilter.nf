process GQfilter {

	tag "$id"
	container "docker://broadinstitute/gatk"

        input:
        tuple val(id), path(vcf), path(vcftbi)
		val GQ 
         

        output:
        tuple val(id), path("${id}.${GQ}.vcf.gz"), path("${id}.${GQ}.vcf.gz.tbi")

        """
        gatk VariantFiltration -V $vcf -G-filter "DP < $GQ" --genotype-filter-name "Depth" --set-filtered-genotype-to-no-call true -O ${id}.${GQ}.vcf.gz 
        """

}