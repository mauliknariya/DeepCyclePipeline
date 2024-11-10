#!/bin/bash
#SBATCH --job-name=QCKG5
#SBATCH -o logs/QCKG5.out
#SBATCH -e logs/QCKG5.err
#SBATCH --mem=64GB
#SBATCH --cpus-per-task=8
#SBATCH --time=2-0:00
#SBATCH --partition=molina

eval "$(conda shell.bash hook)"
conda activate snakemake8
touch config.yaml
snakemake --nolock --cores 8 --snakefile rnavelo.smk --configfile config.yaml --rerun-incomplete \
          --until /shared/space2/molina/Data/hiPSCs_timecourse_scrna/QCKG5/deepcycle
