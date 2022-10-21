process genotypeGVCFs {

	tag "$id"
		 time { 10.hour * task.attempt }
		 errorStrategy 'retry' 
		maxRetries 3
		container "docker://broadinstitute/gatk"
	cpus 4


	
	input:
	tuple val(id), path(vcf), path(vcftbi)
        path genome 
        path indexes
		path dict		
		path interval
		path alleles
	
	output:
	tuple val(id), path("${id}.vcf.gz"), path("${id}.vcf.gz.tbi")
	
"""
	gatk GenotypeGVCFs -R $genome -V $vcf -O ${id}.vcf.gz --force-output-intervals $alleles --sequence-dictionary $dict -L $interval --call-genotypes true -all-sites true
	gatk SelectVariants -R $genome -V ${id}.temp.vcf.gz -O ${id}.vcf.gz --concordance $alleles
"""

}