__author__ = 'Maulik Nariya'
__date__ = 'March 2024'
__copyright__ = 'MIT license'

import os

samples = ["QCKG5", "QCKG6", "QCKG14", "QCKG15", "QCKG16"]
samples_path = config["samples_path"]

ref_genome = config["genome_human"]
go_annot = config["cellcycleGO_human"]

rule all:
    input: 
        expand("/shared/space2/molina/Data/hiPSCs_timecourse_scrna/{sample}", sample=samples)

rule cellranger_count:
    input:
        "%s/{sample}/fastqs"%samples_path
    output:
        directory("%s/{sample}/cellranger"%samples_path)
    params:
        genome = ref_genome,
        path = samples_path
    log:
        "logs/cellranger_{sample}.out"
    threads: 8
    run:
        if os.path.isdir("%s/{wildcards.sample}/cellranger/outs"):
            shell('echo "Will not run cellranger_count"')
        else:
            shell('set +o pipefail && \
                   cd "{params.path}/{wildcards.sample}" && \
                   module load cellranger && \
                   cellranger count --id=cellranger \
                                    --transcriptome={params.genome} \
                                    --fastqs={input} \
                                    --sample={wildcards.sample}')

rule velocyto:
    input:
         "%s/{sample}/cellranger"%samples_path
    output:
        directory("%s/{sample}/velocyto"%samples_path)
    params:
        genome = ref_genome
    log:
        "logs/velocyto_{sample}.out"
    shell:
        '''
        eval "$(conda shell.bash hook)"
        conda activate velocyto
        module load samtools
        velocyto run --bcfile {input}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
                     --outputfolder {output} \
                     {input}/outs/possorted_genome_bam.bam {params.genome}/genes/genes.gtf
        conda deactivate
        '''

rule scvelo:
    input:
        "%s/{sample}/velocyto"%samples_path
    output:
        directory("%s/{sample}/scvelo"%samples_path)
    log:
        "logs/scvelo_{sample}.out"
    shell:
        '''
        eval "$(conda shell.bash hook)"
        conda activate scvelo
        python scvelo_moments.py {input} {output}
        conda deactivate
        '''

rule deepcycle:
    input:
        "%s/{sample}/scvelo"%samples_path
    output:
        directory("%s/{sample}/deepcycle"%samples_path)
    params:
        gene_list = go_annot
    threads : 8
    log:
        "logs/deepcycle_{sample}.out"
    shell:
        '''
        eval "$(conda shell.bash hook)"
        conda activate deepcycle
        python DeepCycle_MKN.py  \
               --input_adata {input}/scvelo.h5ad \
               --gene_list {params.gene_list} \
               --expression_threshold 0.5 \
               --hotelling \
               --output_dir {output}
               conda deactivate
        '''

ruleorder: all > cellranger_count > velocyto > scvelo > deepcycle
