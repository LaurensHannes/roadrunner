process sortbam {


	tag "$id"
        input:
        tuple val(id), path(sams)

        output:
		tuple val(id), path("${id}.sorted.bam"), path("${id}.sorted.bam.bai")

        """
        samtools view -bS $sams | samtools sort -o ${id}.sorted.bam
        samtools index ${id}.sorted.bam
        """
}