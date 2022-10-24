process GQfilter {

	tag "$id"
	container "docker://laurenshannes/revivid"

        input:
        tuple val(id), path(vcf), path(vcftbi)
		val GQ 
         

        output:
        tuple val(id), path("${id}.${GQ}.vcf.gz"), path("${id}.${GQ}.vcf.gz.tbi")

        """
        gatk VariantFiltration -V $vcf -O temp.${vcf} -G-filter "isHomRef == 1" --genotype-filter-name "homref" -G-filter "isHomVar ==1" --genotype-filter-name "homvar" -G-filter "isHet ==1" --genotype-filter-name "hez"
cat <(grep '^#' temp.${vcf}) <(grep 'hez' temp.${vcf})  > heterozygotes.vcf
cat <(grep '^#' temp.${vcf}) <(grep 'hom[rv][ae][rf]' temp.${vcf})  > homozygotes.vcf
sed -e 's/:FT//g' heterozygotes.vcf | sed -e 's/:hez//g' > testheterozygotes.vcf
sed -e 's/:FT//g' homozygotes.vcf | sed -e 's/:hom[rv][ae][fr]//g' > testhomozygotes.vcf
gatk VariantFiltration -V testheterozygotes.vcf -O heterozygotes_dpfiltered.vcf -G-filter "DP < 2" --genotype-filter-name "dphez" --set-filtered-genotype-to-no-call true --invalidate-previous-filters true
gatk VariantFiltration -V testhomozygotes.vcf -O homozygotes_dpfiltered.vcf -G-filter "DP < 7" --genotype-filter-name "dphoz" --set-filtered-genotype-to-no-call true --invalidate-previous-filters true
sed -ie 's/:FT//g' heterozygotes_dpfiltered.vcf 
sed -ie 's/:dphez//g' heterozygotes_dpfiltered.vcf
sed -ie 's/:FT//g' homozygotes_dpfiltered.vcf 
sed -ie 's/:dphoz//g' homozygotes_dpfiltered.vcf
bgzip homozygotes_dpfiltered.vcf
tabix homozygotes_dpfiltered.vcf.gz
bgzip heterozygotes_dpfiltered.vcf
tabix heterozygotes_dpfiltered.vcf.gz
gatk MergeVcfs -I homozygotes_dpfiltered.vcf.gz -I heterozygotes_dpfiltered.vcf.gz -O ${id}.${GQ}.vcf.gz
        """

}