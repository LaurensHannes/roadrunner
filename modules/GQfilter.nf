process GQfilter {

	tag "$id"
	container "docker://broadinstitute/gatk"

        input:
        tuple val(id), path(vcf), path(vcftbi)
		val GQ 
         

        output:
        tuple val(id), path("${id}.${GQ}.vcf)

        """
        gatk FilterVcf -I $vcf --MIN_GQ $GQ -O ${id}.${GQ}.vcf
        """

}