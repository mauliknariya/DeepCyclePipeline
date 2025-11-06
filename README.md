# Snakemake pipeline for running DeepCycle on single-cell RNA-seq data

The pipeline executes the following tools on a given dataset:
```
cellranger
    |
velocyto
    |
scVelo
    |
DeepCycle
```
**Note**: You must have these tools installed in separate conda environments. You must also have the relevant fastq files in  `/PATH/TO/SAMPLE/fastq`

The pipeline was prototyped on Snakemake version 8.5.0
