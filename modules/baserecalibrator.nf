process baserecalibrator {

	tag "$lane"
	cpus 1
	time { 30.minute * task.attempt }
	errorStrategy 'retry' 
	maxRetries 3
	container "broadinstitute/gatk"
	memory { 4.GB * task.attempt }

	
        input:
        tuple val(id), val(lane), file(merged), file(bai) 
        path genome 
		path indexes
        path dict 
		path snps
        path snpsindex 

        output:
        tuple val(id), val(lane), file(merged), file(bai), file("${lane}.recal_data.table") 

        """
        gatk BaseRecalibrator -I $merged -R $genome -O ${id}.${chr}.recal_data.table --known-sites $snps --verbosity WARNING
        """
}