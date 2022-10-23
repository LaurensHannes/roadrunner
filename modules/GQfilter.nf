process GQfilter {

	tag "$id"
	container "docker://broadinstitute/gatk"

        input:
        tuple val(id), path(vcf), path(vcftbi)
		val GQ 
         

        output:
        tuple val(id), path("${id}.${GQ}.vcf.gz"), path("${id}.${GQ}.vcf.gz.tbi")

        """
        gatk FilterVcf -I $vcf --MIN_DP $GQ -O ${id}.temp.${GQ}.vcf.gz 
        gatk SelectVariants -V  ${id}.temp.${GQ}.vcf.gz -O ${id}.${GQ}.vcf.gz --set-filtered-gt-to-nocall true
        """

}