process combineGVCFs {

	tag "$id"
	cpus 4
	time { 2.hour * task.attempt }
		 errorStrategy 'retry' 
		maxRetries 3
		container "broadinstitute/gatk"
	stageInMode	'copy'
		
	input:
	tuple val(family), path(vcf1)
	path genome 
	path indexes
	path dict
	
	output:
	tuple val(family), path("${family}.g.vcf.gz"), path("${family}.g.vcf.gz.tbi")
	
"""
	gatk IndexFeatureFile -I $vcf1

	gatk CombineGVCFs -R $genome -V $vcf1 -O ${id}.g.vcf.gz
"""

}