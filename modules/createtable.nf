process createtable {

		tag "$run"
		publishDir "./results/$run", mode: 'copy', overwrite: true

        input:
        tuple val(run), val(GQ), path(vcf)


        output:
        tuple val(run), val(GQ), path("${run}.${GQ}.genotypes.tsv")


		"""
		plink1.9 --vcf $vcf --allow-no-sex --recode --out table --make-bed --double-id
		transpose -t -l 2000x2000 --fsep " " table.ped > table.transposed.ped
		head -n 1 table.transposed.ped > header.transposed.ped
		sed -i '1,6d' table.transposed.ped
		rm table.ped
		transpose -t -l 2000x2000 --fsep " " table.transposed.ped > table.ped
		sed -i "s/[^ ]\$/& /;s/ \\([^ ]*\\) /\\|\\1 /g" table.ped
		rm table.transposed.ped
		transpose -t -l 2000x2000 --fsep " " table.ped > table.transposed.ped
		cat header.transposed.ped table.transposed.ped > table_cut.ped
		sed -i -e 's/ /\\t/g' table_cut.ped
		cat table.map | cut -f 1,2,4 > table_cut.map
		sed -i -e '1s/^/chr\\tid\\tpos\\n/' table_cut.map
		paste table_cut.map table_cut.ped > ${run}.${GQ}.genotypes.tsv

"""

}

