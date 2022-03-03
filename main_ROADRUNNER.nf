#! usr/bin/env nextflow


nextflow.enable.dsl=2

log.info """\

 R O A D R U N N E R - W G S - P I P E L I N E
 =============================================
 #############################################
 ################## DSL 2 ####################
 ################## W I P ####################
 ################## alpha ####################
 #############################################
 =============================================
 """

//includes 

include { unzip } from './modules/unzip.nf'
include { fastQC } from './modules/fastQC.nf'
include { alignment } from './modules/alignment.nf'
include { pear } from './modules/pear.nf'
include { duplicates } from './modules/duplicates.nf'
include { mipgenPE } from './modules/mipgenPE.nf'
include { prepare_interval } from './modules/prepare_interval.nf'
include { mipgenparam } from './modules/mipgenparam.nf'

//channels


run = channel.value('run10')
tools =channel.fromPath(params.tools)
GQ_ch = channel.value(30)
barcodes_ch = Channel.fromPath(params.barcodes)
indexes_ch = Channel.fromPath(params.indexes).toList()


workflow { 
main:
prepare_interval(params.designbed)
unzip(params.rawdata)
unzip.out[0].flatten().filter(~/.*R\d+.fastq.gz/).map{file -> tuple(file.getBaseName(3), file)}.groupTuple().dump(tag:"test").flatten().collate( 3 ).map{lane,R1,R2 -> tuple(R1.simpleName,lane,R1,R2)}.set{gzipped_ch}
fastQC(gzipped_ch)
pear(gzipped_ch)
mipgenPE(pear.out[0],barcodes_ch)
alignment(mipgenPE.out[0],params.genome,channel.indexes_ch)
mipgenparam(alignment.out[0],param.barcodes,params.mips)

}