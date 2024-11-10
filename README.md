# Snakemake pipeline for running DeepCycle on single-cell RNA-seq data

The pipeline executes the following tolls on a given dataset:
```
cellranger
    |
velocyto
    |
scVelo
    |
DeepCycle
```
**Note**: You must have these tools installed in separate conda environments.

The pipeline was prototyped on Snakemake version 8.5.0
