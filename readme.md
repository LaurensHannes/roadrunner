```markdown
# Roadrunner Pipeline

This repository contains the Roadrunner pipeline, a Nextflow-based workflow for genomic data processing and analysis. The pipeline includes various modules for tasks such as alignment, base quality score recalibration, variant calling, and more.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Pipeline Structure](#pipeline-structure)
- [Configuration](#configuration)
- [Modules](#modules)
- [License](#license)

## Installation

To run the Roadrunner pipeline, you need to have the following software installed:

- [Nextflow](https://www.nextflow.io/)
- [Docker](https://www.docker.com/) or [Singularity](https://sylabs.io/singularity/)

Clone the repository:

```sh
git clone https://github.com/yourusername/roadrunner.git
cd roadrunner
```

## Usage

To run the pipeline, use the following command:

```sh
nextflow run main_ROADRUNNER.nf -profile docker -params-file params_laptoprun20designD.yml
```

## Pipeline Structure

The repository is structured as follows:

```
.gitattributes
main_ROADRUNNER.nf
modules/
    alignment.nf
    applyBQSR.nf
    baserecalibrator.nf
    combineGVCFs.nf
    combinewise.nf
    createrunvcf.nf
    createtable.nf
    createwisefiles.nf
    duplicates.nf
    fastQC.nf
    genotype.nf
    genotypeGVCFs.nf
    GQfilter.nf
    mergebams.nf
    metrics.nf
    metrics.nfe
    mipgenparam
    mipgenparam.nf
    mipgenPE.nf
    offtargetcount.nf
    pear.nf
    prepare_interval.nf
    sortbam.nf
    unzip.nf
nextflow.config
params_laptoprun20designD.yml
scripts/
    createtable.py
```

## Configuration

The pipeline configuration is managed through the [`nextflow.config`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fnextflow.config%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/nextflow.config") file and parameter files such as [`params_laptoprun20designD.yml`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fparams_laptoprun20designD.yml%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/params_laptoprun20designD.yml").

### nextflow.config

The [`nextflow.config`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fnextflow.config%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/nextflow.config") file contains profiles for running the pipeline with Docker or Singularity:

```config
profiles {
    singularity {
        singularity.enabled    = true
        singularity.autoMounts = true
        docker.enabled         = false
        podman.enabled         = false
        shifter.enabled        = false
        charliecloud.enabled   = false
        container = 'docker://laurenshannes/roadrunner'
    }
    docker {
        docker.enabled         = true
        docker.userEmulation   = true
        singularity.enabled    = false
        podman.enabled         = false
        shifter.enabled        = false
        charliecloud.enabled   = false
        process.container = 'laurenshannes/roadrunnerdocker'
        process.maxForks = 8
        process.cpus = 1
        docker.legacy = false
        docker.runOptions = '-v /mnt/c:/mnt/c'
    }
}
tower {
  accessToken = 'c6f9fe249f9a24a49cf3d19f7bedcb1983786788'
  enabled = true
}
cleanup = true
```

### params_laptoprun20designD.yml

This file contains parameters specific to the run:

```yml
indexes: '/home/laurens/resources/hg19/hg19.fa.*' 
genomedict: '/home/laurens/resources/hg19/hg19.dict'
genome: '/home/laurens/resources/hg19/hg19.fa'
Readdirection: ['R1', 'R2']
mips: '/mnt/c/research/roadrunner/2020/designfiles/designD.txt'
barcodes: '/mnt/c/research/roadrunner/2020/barcodes/run20barcodes.txt'
rawdata: '/mnt/c/research/roadrunner/rawdata/run20.zip'
designbed: '/mnt/c/research/roadrunner/2020/designfiles/designD_fixed.bed'
output: '/mnt/c/research/roadrunner/2020/runs/run20'
snps: '/mnt/c/research/roadrunner/broadhg19/1000G_phase1.snps.high_confidence.b37.vcf.gz'
snpsindex: '/mnt/c/research/roadrunner/broadhg19/1000G_phase1.snps.high_confidence.b37.vcf.gz.tbi'
indels: '/mnt/c/research/roadrunner/broadhg19/Mills_and_1000G_gold_standard.indels.b37.vcf.gz'
indelsindex: '/mnt/c/research/roadrunner/broadhg19/Mills_and_1000G_gold_standard.indels.b37.vcf.gz.tbi'
alleles: '/mnt/c/research/roadrunner/designs/2020/allvariants2.vcf'
allelesidx: '/mnt/c/research/roadrunner/designs/2020/allvariants2.vcf.idx'
run: 'run20'
GQ: '20'
DP: '20'
targets: '/mnt/c/research/roadrunner/2020/designfiles/designDtargets.txt'
```

## Modules

The pipeline is composed of several modules, each responsible for a specific task. Below are some of the key modules:

- **Alignment**: [`modules/alignment.nf`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fmodules%2Falignment.nf%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/modules/alignment.nf")
- **Base Quality Score Recalibration**: [`modules/applyBQSR.nf`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fmodules%2FapplyBQSR.nf%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/modules/applyBQSR.nf"), [`modules/baserecalibrator.nf`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fmodules%2Fbaserecalibrator.nf%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/modules/baserecalibrator.nf")
- **Variant Calling**: [`modules/genotype.nf`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fmodules%2Fgenotype.nf%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/modules/genotype.nf"), [`modules/genotypeGVCFs.nf`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fmodules%2FgenotypeGVCFs.nf%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/modules/genotypeGVCFs.nf")
- **Quality Control**: [`modules/fastQC.nf`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fmodules%2FfastQC.nf%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/modules/fastQC.nf")
- **Metrics Calculation**: [`modules/metrics.nf`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fmodules%2Fmetrics.nf%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/modules/metrics.nf"), [`modules/metrics.nfe`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fmnt%2Fc%2FUsers%2Flaure%2FOneDrive%2FDocumenten%2FGitHub%2Froadrunner%2Fmodules%2Fmetrics.nfe%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "/mnt/c/Users/laure/OneDrive/Documenten/GitHub/roadrunner/modules/metrics.nfe")

## License

This project is licensed under the MIT License. See the LICENSE file for details.
```

