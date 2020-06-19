#!bin/bash
set -e

if [[ ! -d input ]]; then
    echo -e "creating input directory\n==========="
    mkdir -p input
    wget -P input/ http://genomedata.org/rnaseq-tutorial/HBR_UHR_ERCC_ds_5pc.tar
    tar -xf input/HBR_UHR_ERCC_ds_5pc.tar -C input/
    echo -e "clean up the downloads\n========="
    rm input/HBR_UHR_ERCC_ds_5pc.tar
fi

if [[ ! -d ref ]]; then
    echo -e "create reference sequence directory\n========="
    mkdir -p ref
    wget -P ref/ http://genomedata.org/rnaseq-tutorial/fasta/GRCh38/chr22_with_ERCC92.fa
    wget -P ref/ http://genomedata.org/rnaseq-tutorial/annotations/GRCh38/chr22_with_ERCC92.gtf
fi

echo -e "rename input files\n========="
#. "$CONDA_PREFIX_1/etc/profile.d/conda.sh"
eval "$(conda shell.bash hook)" # this is better than the above command. more general
conda env create -f env/rename.yaml
conda activate rename

#parse the input files

rename 's/(.*)(ERCC.*chr22\.)(.*)/$1$3/' input/*.fastq.gz
echo -e "Done!\n========="
