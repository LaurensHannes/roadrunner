process metrics {

	tag "$run"
	container "docker://laurenshannes/revivid"	
	publishDir "./results/$run/metrics", mode: 'copy', overwrite: true


        input:
       	tuple val(run), val(GQ), path(vcf)
	path targets 
         

        output:
	
	path("${run}.${GQ}.imiss")
	path("${run}.${GQ}.lmiss")        
	path("${run}.${GQ}.metrics.log")	

	script:


        """
	plink1.9 --vcf $vcf  --recode    --out ${run}.${GQ}.temp --make-bed --missing -extract $targets
perl -i -pe 's/^\s+//g' ${run}.${GQ}.temp.imiss 
perl -i -pe 's/^\s+//g' ${run}.${GQ}.temp.lmiss
perl -i -pe 's/ \s*/\t/g' ${run}.${GQ}.temp.imiss 
perl -i -pe 's/ \s*/\t/g' ${run}.${GQ}.temp.lmiss 
cut -f 1,2,4,5,6 ${run}.${GQ}.temp.imiss > ${run}.${GQ}.subset.imiss
paste ${run}.${GQ}.subset.imiss <(cat <(echo "callrate") <(awk "{print (1-\$5)}" ${run}.${GQ}.subset.imiss | sed -e "1d")) > ${run}.${GQ}.imiss
paste ${run}.${GQ}.temp.lmiss <(cat <(echo "callrate") <(awk "{print (1-\$5)}" ${run}.${GQ}.temp.lmiss | sed -e "1d")) > ${run}.${GQ}.lmiss
egrep 'Total genotyping rate' ${run}.${GQ}.temp.log >> ${run}.${GQ}.metrics.log
"""
} 
