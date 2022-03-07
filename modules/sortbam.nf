process sortbam {


	tag "$lane"
        input:
        tuple val(id), val(lane), path(sams)

        output:
		tuple val(id), val(lane), path('${lane}.sorted.bam'), path('${lane}.sorted.bam.bai')

        """
        samtools view -bS $sams | samtools sort -o ${lane}.sorted.bam
        samtools index ${lane}.sorted.bam
        """
}