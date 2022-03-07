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
include { mipgenPE } from './modules/mipgenPE.nf'
include { prepare_interval } from './modules/prepare_interval.nf'
include { mipgenparam } from './modules/mipgenparam.nf'
include { sortbam } from './modules/sortbam.nf'
include { applyBQSR } from './modules/applyBQSR.nf'
include { baserecalibrator } from './modules/baserecalibrator.nf'
include { genotype } from './modules/genotype.nf'
include { combineGVCFs } from './modules/combineGVCFs.nf'
include { genotypeGVCFs } from './modules/genotypeGVCFs.nf'


//channels


run = channel.value('run10')
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
mipgenPE(pear.out[0],params.barcodes)
alignment(mipgenPE.out[0],params.genome,indexes_ch)
mipgenparam(alignment.out[0],params.barcodes,params.mips)
sortbam(mipgenparam.out[0])
baserecalibrator(sortbam.out[0],params.genome, indexes_ch, params.genomedict, params.snps, params.snpsindex)
applyBQSR(baserecalibrator.out,params.genome,indexes_ch,params.genomedict)
genotype(applyBQSR.out,params.genome,indexes_ch,params.broadinterval,params.genomedict,params.mask)
combineGVCFs(genotype.out[0],params.genome,indexes_ch,params.genomedict)
genotypeGVCFs(combineGVCFs.out[0],params.genome,indexes_ch,params.broadinterval,params.genomedict,params.mask)

}