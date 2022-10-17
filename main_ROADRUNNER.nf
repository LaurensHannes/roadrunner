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
include { mergebams } from './modules/mergebams.nf'
include { prepare_interval } from './modules/prepare_interval.nf'
include { mipgenparam } from './modules/mipgenparam.nf'
include { sortbam } from './modules/sortbam.nf'
include { applyBQSR } from './modules/applyBQSR.nf'
include { baserecalibrator } from './modules/baserecalibrator.nf'
include { genotype } from './modules/genotype.nf'
include { combineGVCFs } from './modules/combineGVCFs.nf'
include { genotypeGVCFs } from './modules/genotypeGVCFs.nf'
include { GQfilter } from './modules/GQfilter.nf'
include { create_run_vcf } from './modules/createrunvcf.nf'
include { offtargetcount } from './modules/offtargetcount.nf'
include { create_wise_files } from './modules/createwisefiles.nf'
include { combined_wise } from './modules/combinewise.nf'
include { createtable } from './modules/createtable.nf'

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
mergebams(alignment.out[0].map{id,lane,bam,bai -> tuple(id,bam)}.groupTuple())
mipgenparam(mergebams.out[0],params.barcodes,params.mips)
sortbam(mipgenparam.out[0])
baserecalibrator(sortbam.out[0],params.genome, indexes_ch, params.genomedict, params.snps, params.snpsindex)
applyBQSR(baserecalibrator.out,params.genome,indexes_ch,params.genomedict)
genotype(applyBQSR.out,params.genome,indexes_ch,prepare_interval.out[0],params.genomedict)
genotypeGVCFs(genotype.out[0],params.genome,indexes_ch,params.genomedict,prepare_interval.out[0])
GQfilter(genotypeGVCFs.out[0],GQ_ch)
create_run_vcf(GQfilter.out[0].map{id,vcfgz,vcftbi -> vcfgz}.flatten().toList(),GQfilter.out[0].map{id,vcfgz,vcftbi -> vcftbi}.flatten().toList(),run,GQ_ch)
offtargetcount(mipgenparam.out[1],params.mips,params.barcodes)
create_wise_files(mipgenparam.out[2].join(offtargetcount.out[0]),mipgenparam.out[3].join(offtargetcount.out[1]),params.barcodes,run)
combine_wise(create_wise_files.out[0].map{id,txt -> txt}.flatten().toList(), create_wise_files.out[1].map{id,txt -> txt}.flatten().toList(),create_wise_files.out[2].map{id,txt -> txt}.first(),run)
createtable(create_run_vcf.out[0])
}