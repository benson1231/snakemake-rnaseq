# gtf_path <- "/home/benson/git/snakemake-rnaseq/workflow/reference/Homo_sapiens.GRCh38.113.gtf.gz"
# transcript_out <- "/home/benson/git/snakemake-rnaseq/workflow/reference/transcript_annotations_113.csv"
# gene_out <- "/home/benson/git/snakemake-rnaseq/workflow/reference/gene_annotations_113.csv"

args <- commandArgs(trailingOnly = TRUE)
gtf_path <- args[1]
transcript_out <- args[2]
gene_out <- args[3]

suppressPackageStartupMessages({
  library(rtracklayer)
  library(dplyr)
  library(org.Hs.eg.db)
  library(AnnotationDbi)
})

# Import GTF
gtf_data <- import(gtf_path)

# Transcript-level
transcript_annotations <- gtf_data[gtf_data$type == "transcript"]
transcript_annotations_df <- as.data.frame(transcript_annotations) %>%
  dplyr::select(seqnames, start, end, strand, gene_id, transcript_id, gene_name, gene_biotype) %>%
  dplyr::mutate(length = end - start + 1)

write.csv(transcript_annotations_df, transcript_out, row.names = FALSE)

# Gene-level
gene_annotations <- gtf_data[gtf_data$type == "gene"]
gene_annotations_df <- as.data.frame(gene_annotations) %>%
  dplyr::select(seqnames, start, end, strand, gene_id, gene_name, gene_biotype) %>%
  dplyr::mutate(length = end - start + 1)

gene_annotations_df$entrez_id <- mapIds(
  org.Hs.eg.db,
  keys = gene_annotations_df$gene_id,
  column = "ENTREZID",
  keytype = "ENSEMBL",
  multiVals = "first"
)

write.csv(gene_annotations_df, gene_out, row.names = FALSE)
