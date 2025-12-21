#!/bin/bash
set -euo pipefail

# ==========
# Conda init
# ==========
source "$(conda info --base)/etc/profile.d/conda.sh"

# Build or activate env
if conda env list | grep -q "r-gtf"; then
    echo ">>> Using existing env r-gtf"
else
    echo ">>> Creating env r-gtf"
    conda env create -f workflow/envs/ref.yaml
fi

conda activate r-gtf

mkdir -p workflow/references

# # ==========
# # Download GTF
# # ==========
GTF_URL="ftp://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz"
GTF_PATH="workflow/references/Homo_sapiens.GRCh38.113.gtf.gz"

wget -O "$GTF_PATH" "$GTF_URL"

# ==========
# Parse GTF
# ==========
Rscript workflow/scripts/parse_gtf.R \
    "$GTF_PATH" \
    workflow/references/transcript_annotations_113.csv \
    workflow/references/gene_annotations_113.csv

# ==========
# Download FASTA
# ==========
FASTA_URL="ftp://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz"
FASTA_PATH="workflow/references/Homo_sapiens.GRCh38.cdna.all.fa.gz"

wget -O "$FASTA_PATH" "$FASTA_URL"

# Build kallisto index
kallisto index -i workflow/references/transcriptome.idx <(zcat "$FASTA_PATH")