process mergebams {

        input:
        path bam from sorted_baserecall_merge_ch.toList()
	path bai from sorted_baserecall_bai_merge_ch.toList()
//	tuple val(x), path(bam), path(bai) from sorted_tuple_ch	

        output:
        path 'merged.bam' into mergedbams_ch

        """
	
        samtools merge -@ 4 -b <(ls $bam) merged.bam
        """

}