# args
args <- commandArgs(trailingOnly = TRUE)
gtf_path <- args[1]
transcript_out <- args[2]
gene_out <- args[3]

suppressPackageStartupMessages({
  library(rtracklayer)
  library(dplyr)
  library(AnnotationHub)
  library(ensembldb)
})

# ------------------------------------------------------------
# 1. 載入 EnsDb（用來取代 org.Hs.eg.db）
# ------------------------------------------------------------
ah <- AnnotationHub()

## GRCh38 GENCODE v38 / Ensembl v105 對應 EnsDb
## 你也可以用 query(ah, "EnsDb.Hsapiens") 查看所有版本
ensdb <- ah[["AH98047"]]   # EnsDb.Hsapiens.v105 (最常用、最穩定)

# ------------------------------------------------------------
# 2. Import GTF
# ------------------------------------------------------------
gtf_data <- import(gtf_path)

# ------------------------------------------------------------
# 3. Transcript-level annotations
# ------------------------------------------------------------
transcript_annotations <- gtf_data[gtf_data$type == "transcript"]
transcript_annotations_df <- as.data.frame(transcript_annotations) %>%
  select(seqnames, start, end, strand, gene_id,
         transcript_id, gene_name, gene_biotype) %>%
  mutate(length = end - start + 1)

write.csv(transcript_annotations_df, transcript_out, row.names = FALSE)

# ------------------------------------------------------------
# 4. Gene-level annotations + ENTREZ ID mapping (不用 org.Hs.eg.db)
# ------------------------------------------------------------
gene_annotations <- gtf_data[gtf_data$type == "gene"]
gene_annotations_df <- as.data.frame(gene_annotations) %>%
  select(seqnames, start, end, strand, gene_id,
         gene_name, gene_biotype) %>%
  mutate(length = end - start + 1)

# 利用 EnsDb 做 ENSEMBL → ENTREZ mapping
gene_annotations_df$entrez_id <- mapIds(
  ensdb,
  keys = gene_annotations_df$gene_id,
  column = "ENTREZID",
  keytype = "GENEID",
  multiVals = "first"
)

write.csv(gene_annotations_df, gene_out, row.names = FALSE)
