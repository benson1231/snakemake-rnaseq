# Load libraries  ---------------------------------------------------------
library(tximport)
library(ComplexHeatmap)
library(magrittr)
library(tidyverse)
library(DESeq2)
library(edgeR)
library(EnhancedVolcano)
library(RColorBrewer)
library(openxlsx)
library(biomaRt)
library(flextable)
library(magrittr)
library(reshape2)


# Read command-line arguments ---------------------------------------------
args <- commandArgs(trailingOnly = TRUE)

# Ensure both 'data_path' and 'ref_path' are provided
if (length(args) < 2) {
  stop("Missing argument: Please provide both the 'data path' and 'reference file path'.")
}

# Assign arguments to path variables
data_path <- args[1]
ref_path <- args[2]



# if testing --------------------------------------------------------------
# data_path <- "/home/benson/project/RNAseq/test_deseq2"
# ref_path <- "/home/benson/refs/release113"



# file path ---------------------------------------------------------------
# project file
output_path <- file.path(data_path, "05_results")

# metadata file
metadata_file_name <- "RNAseq_metadata.xlsx"

# annotation file
transcript_annotations_path <- file.path(ref_path, "annotation", "transcript_annotations_113.csv")
gene_annotations_path <- file.path(ref_path, "annotation", "gene_annotations_113.csv")

# Create output directory if it doesn’t exist
if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE)
# Set working directory to the output folder
setwd(output_path)
message("Set working directory to: ", output_path)


# add folders --------------------------------------------------------------
folders <- c("01_counts", "02_figures", "03_summary_table", "04_pathway")
for (folder in folders) {
  dir.create(file.path(output_path, folder), recursive = TRUE, showWarnings = FALSE)
}


# load file ---------------------------------------------------------------
# Read gene annotation file and extract gene_id and gene_name
gene_annotations <- read.csv(gene_annotations_path, header = TRUE, stringsAsFactors = FALSE)
ensembl_symbol_df <- gene_annotations %>%
  dplyr::select(gene_id, gene_name) %>%
  setNames(c("ensembl", "symbol"))
message("Loaded gene annotations from: ", gene_annotations_path,
        " (", nrow(gene_annotations), " records)")

# Read transcript annotation file and extract transcript-to-gene mapping
transcript_annotations <- read.csv(transcript_annotations_path, header = TRUE, stringsAsFactors = FALSE) %>%
  dplyr::select(transcript_id, gene_id)
message("Loaded transcript annotations from: ", transcript_annotations_path,
        " (", nrow(transcript_annotations), " records)")

# Load sample metadata from Excel
sample_info <- readxl::read_xlsx(file.path(data_path, metadata_file_name), sheet = "sample_info") %>%
  mutate(row_name = sample_name) %>%               # Use sample_name as row names
  column_to_rownames("row_name")
message("Loaded sample metadata from: ", file.path(data_path, metadata_file_name),
        " (", nrow(sample_info), " samples)")

# Convert grouping columns to factors
sample_info$condition <- factor(sample_info$condition, levels = unique(sample_info$condition))
sample_info$abbreviation_name <- factor(sample_info$abbreviation_name, levels = unique(sample_info$abbreviation_name))
condition <- factor(sample_info$condition, levels = unique(sample_info$condition))
group <- factor(sample_info$condition)

# Preview sample information
head(sample_info)

# Set default flextable appearance: white background, black text
set_flextable_defaults(
  background.color = "white",
  font.color = "black"
)

# ========================================
# Save sample metadata as table image
# ========================================
info <- readxl::read_xlsx(file.path(data_path, metadata_file_name), sheet = "sample_info") %>%
  mutate(row_name = abbreviation_name) %>%
  column_to_rownames("row_name")

sample_info_ft <- flextable(info)  # Create flextable object
save_as_image(sample_info_ft, "02_figures/Sample information.png")  # Save table as PNG
message("Sample metadata table saved as image: 'Sample information.png'")



# Prepare sample color mapping -------------------------------------------
# Extract unique condition-color pairs from sample_info
color_list_df <- sample_info %>%
  dplyr::select(condition, color) %>%     # Select relevant columns
  dplyr::distinct() %>%                   # Remove duplicate rows
  dplyr::filter(!is.na(condition) & !is.na(color))  # Exclude any NA values

# Create a named vector: color[condition] = color_code
sample_color_list <- setNames(color_list_df$color, color_list_df$condition)

# Print the result to verify
print(sample_color_list)



# Load group comparison info from Excel ----------------------------------
# Read second sheet for condition comparisons (Treatment vs Control)
comparisons <- readxl::read_xlsx(
  path = file.path(data_path, metadata_file_name),
  sheet = "sample_comparisons"
) %>%
  dplyr::mutate(Comparison = paste0(Treatment, "_vs_", Control)) %>%  # Create combined label
  dplyr::select(Comparison, Treatment, Control)

# ========================================
# Save comparison table as image for reports or tracking
# ========================================
comparisons_ft <- flextable(comparisons)
save_as_image(comparisons_ft, "02_figures/Sample comparisons.png")
message("Sample comparisons table saved as image: 'Sample comparisons.png'")



# Prepare Kallisto abundance file paths ----------------------------------
# Construct file paths for each sample's abundance.tsv
files <- file.path(data_path, "03_kallisto_quant", sample_info$sample_name, "abundance.tsv")
names(files) <- sample_info$sample_name  # Name each file by sample
message("Loaded Kallisto abundance paths for ", length(files), " samples.")



# Import expression data using tximport ----------------------------------
txi.kallisto <- tximport(
  files = files,
  type = "kallisto",
  tx2gene = transcript_annotations,  # Transcript-to-gene mapping
  txOut = FALSE                      # Summarize to gene level
)

message("Imported gene-level expression matrix with ", 
        nrow(txi.kallisto$counts), " genes and ", 
        ncol(txi.kallisto$counts), " samples.")



# Create DESeq2 dataset --------------------------------------------------
dds <- DESeqDataSetFromTximport(
  txi.kallisto,
  colData = sample_info,
  design = ~ condition  # Define model based on experimental condition
)

message("DESeqDataSet object created with ", 
        nrow(dds), " genes and ", 
        ncol(dds), " samples.")

# save raw count
raw_count <- counts(dds)
write.csv(raw_count, file = file.path(output_path, "01_counts/raw_count.csv"))
message("Saved raw count matrix to 'raw_count.csv'")



# plot boxplot before & after normalization -------------------------------
# ========================================
# Sample name mapping
# ========================================
sample_name_map <- sample_info$abbreviation_name
names(sample_name_map) <- rownames(sample_info)

# ========================================
# Pre-filter genes based on CPM threshold
# ========================================
message("Creating raw DGEList and filtering low-expression genes...")

dge_filtered <- counts(dds) %>%
  edgeR::DGEList() %>%
  {
    keep <- rowSums(edgeR::cpm(.) >= 1) >= (ncol(.) / 2)
    message("Genes retained after CPM filtering: ", sum(keep))
    .[keep, , keep.lib.sizes = FALSE]
  }

# ========================================
# Normalize filtered DESeq2 object
# ========================================
dds <- dds[rownames(dge_filtered), ]
dds <- DESeq(dds)
message("DESeq2 normalization complete (RLE size factors estimated).")

# ========================================
# Raw log2 CPM (Before normalization)
# ========================================
log2_cpm_raw <- counts(dds, normalized = FALSE) %>%
  edgeR::cpm(log = FALSE) %>%
  `+`(1) %>%
  log2() %>%
  set_colnames(sample_name_map[colnames(.)])

# ========================================
# Normalized counts → log2 CPM
# ========================================
log2_cpm_norm <- counts(dds, normalized = TRUE) %>%
  edgeR::DGEList() %>%
  edgeR::cpm(log = FALSE) %>%
  `+`(1) %>%
  log2() %>%
  set_colnames(sample_name_map[colnames(.)])

# ========================================
# Visualization: Boxplot before & after normalization
# ========================================
# Combine raw and normalized in long format
df_plot <- bind_rows(
  log2_cpm_raw %>%
    melt() %>%
    setNames(c("gene", "sample", "log2_CPM")) %>%
    mutate(Normalization = "Before"),
  
  log2_cpm_norm %>%
    melt() %>%
    setNames(c("gene", "sample", "log2_CPM")) %>%
    mutate(Normalization = "After")
) %>%
  mutate(Normalization = factor(Normalization, levels = c("Before", "After")))

p <- df_plot %>%
  ggplot(aes(x = sample, y = log2_CPM, fill = Normalization)) +
  geom_boxplot(outlier.size = 0.3, lwd = 0.2) +
  facet_wrap(~Normalization, nrow = 1) +
  theme_bw(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        strip.background = element_blank(),
        strip.text = element_text(size = 14)) +
  labs(title = "Log2 CPM per Sample (Before vs. After Normalization)",
       x = "Sample", y = "Log2 CPM") +
  scale_fill_manual(values = c("Before" = "#FDB863", "After" = "#80B1D3"))

print(p)
ggsave("02_figures/boxplot_log2CPM.png", p, width = 10, height = 6)
message("Boxplot saved as 'boxplot_log2CPM.png'")

# ========================================
# Perform DE analysis and annotate results for each comparison
# ========================================
annotated_results_list <- list()  # Initialize list to store results

for (i in 1:nrow(comparisons)) {
  contrast_name <- comparisons$Comparison[i]
  treatment <- comparisons$Treatment[i]
  control <- comparisons$Control[i]
  
  # Run DESeq2 results for the specified contrast (Treatment vs Control)
  res <- results(dds, contrast = c("condition", comparisons$Treatment[i], comparisons$Control[i]))
  message("\n===== Running DESeq2 for comparison: ", contrast_name, " (", treatment, " vs ", control, ") =====")
  
  # Sort results by adjusted p-value
  res_sorted <- res[order(res$padj), ]
  
  # Convert to data frame for further manipulation
  res_df <- as.data.frame(res_sorted)
  res_df$genes <- rownames(res_df)  # Add gene ID as a column
  
  # Join with gene annotation metadata
  annotated_result <- res_df %>%
    dplyr::select(genes, baseMean, log2FoldChange, pvalue, padj) %>%
    setNames(c("gene_id", "baseMean", "log2FoldChange", "pvalue", "padj")) %>%
    left_join(gene_annotations, by = "gene_id") %>%
    dplyr::select(
      gene_id, gene_name, baseMean,log2FoldChange, pvalue, padj,
      entrez_id, gene_biotype, start, end, length, strand
    ) %>%
    setNames(c(
      "ensembl", "symbol", "baseMean", "log2FoldChange", "p_value", "padj",
      "entrez", "biotype", "start", "end", "length", "strand"
    ))
  message("Annotation complete. Annotated ", nrow(annotated_result), " genes.")
  
  # Store the annotated result with comparison name as list key
  annotated_results_list[[comparisons$Comparison[i]]] <- annotated_result
  message("Stored result for comparison: ", contrast_name)
}

# ========================================
# Export each comparison result to a separate Excel file 
# ========================================
for (comparison_name in names(annotated_results_list)) {
  
  message("\n=== Exporting annotated DE results for: ", comparison_name, " ===")
  # Get result table for the current comparison
  current_result <- annotated_results_list[[comparison_name]]
  
  # Create a new Excel workbook and add a worksheet
  wb <- createWorkbook()
  addWorksheet(wb, comparison_name)
  
  # Write data to worksheet
  writeData(wb, sheet = comparison_name, x = current_result)
  
  # Enable autofilter on the header row
  addFilter(wb, sheet = comparison_name, rows = 1, cols = 1:ncol(current_result))
  
  # Auto-adjust column widths
  setColWidths(wb, sheet = comparison_name, cols = 1:ncol(current_result), widths = "auto")
  
  # Define output filename and save the workbook
  output_file <- paste0("edger_result_", comparison_name, ".xlsx")
  saveWorkbook(wb, file = file.path(output_path, "03_summary_table", output_file), overwrite = TRUE)
  
  # Print progress message
  message("Saved Excel file: ", output_file)
}



# Summarize gene-level expression by gene symbol --------------------------
gene_count <- log2_cpm_norm %>%
  as.data.frame() %>%
  mutate(ensembl = rownames(.)) %>%                         # Add Ensembl ID as a column
  left_join(ensembl_symbol_df, by = "ensembl") %>%          # Map to gene symbols
  filter(!is.na(symbol)) %>%                                # Remove entries without gene symbol
  group_by(symbol) %>%                                      # Group by gene symbol
  summarise(across(where(is.numeric), ~ sum(.x, na.rm = TRUE))) %>%  # Sum expression if multiple Ensembl IDs per symbol
  ungroup() %>%
  column_to_rownames("symbol") %>%                          # Set gene symbol as row names
  dplyr::select(sample_info$abbreviation_name) %>%                # Ensure column order matches sample info
  setNames(sample_info$abbreviation_name)                   # Rename columns using abbreviations

message("Gene symbols: ", nrow(gene_count), 
        " | Samples: ", ncol(gene_count))



# 1. Euclidean Distance Heatmap --------------------------------------------

# Calculate Euclidean distance between samples (rows = genes, cols = samples)
dist_matrix <- dist(t(gene_count))
dist_matrix_mat <- as.matrix(dist_matrix)

# Define color palette
colors <- colorRampPalette(rev(brewer.pal(9, "Blues")))(255)

# Save heatmap to PNG
png("02_figures/Euclidean Distance.png", width = 800, height = 700, res = 100)
ComplexHeatmap::Heatmap(
  dist_matrix_mat,
  name = "Euclidean Distance",
  cluster_rows = TRUE,
  cluster_columns = TRUE,
  show_row_names = TRUE,
  show_column_names = TRUE,
  col = colors
)
dev.off()
message("Euclidean heatmap saved as 'Euclidean Distance.png'.")



# 2. PCA Plot ----------------------------------------------------------------

tryCatch({
  # Perform PCA on transposed gene count matrix (samples as rows)
  pca_res <- prcomp(t(gene_count), scale. = TRUE)
  pca_df <- as.data.frame(pca_res$x)
  
  # Calculate variance explained by each principal component
  percentVar <- round((pca_res$sdev^2 / sum(pca_res$sdev^2)) * 100, 2)
  
  # Add sample and condition info
  pca_df <- pca_df %>%
    mutate(sample = rownames(.)) %>% 
    left_join(sample_info[, c("abbreviation_name", "condition")],
              by = c("sample" = "abbreviation_name"))
  
  # Plot PCA
  ggplot(pca_df, aes(x = PC1, y = PC2, color = condition, label = condition)) +
    geom_point(size = 3) +
    geom_text(vjust = 1.56, size = 3.5) +
    scale_color_manual(values = sample_color_list) +
    labs(
      title = "PCA",
      x = paste0("PC1: ", percentVar[1], "%"),
      y = paste0("PC2: ", percentVar[2], "%")
    ) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5)) +
    guides(color = guide_legend(override.aes = list(size = 5)))
  
  ggsave("02_figures/PCA plot.png", width = 7, height = 7)
  
}, error = function(e) {
  warning("PCA could not be performed or plotted. Please check the gene count matrix and sample size.")
})



# 3. MDS Plot ----------------------------------------------------------------

tryCatch({
  
  # Save MDS plot to PNG
  png("02_figures/MDS plot.png", width = 800, height = 700, res = 100)
  
  # Set plot margins and allow drawing outside the plot region
  par(mar = c(5, 4, 4, 6), xpd = NA)
  
  # Draw MDS plot (plotMDS does not automatically include a legend)
  plotMDS(dds,
          col = sample_color_list[as.character(sample_info$condition)],
          pch = 20,
          cex = 1.5)
  title("Multidimensional scaling (MDS) plot")
  
  # Add custom legend outside the right margin of the plot
  legend(x = par("usr")[2] + 0.01,         # A bit to the right of the plot's right edge
         y = par("usr")[4],                # Align with the top of the y-axis
         legend = names(sample_color_list),
         fill = sample_color_list,
         bty = "n",                        # No border box
         xpd = NA,                         # Allow drawing outside plot region
         cex = 1)                          # Font size
  
  dev.off()
  message("MDS plot saved as 'MDS plot.png'.")
  
}, error = function(e) {
  warning("MDS could not be plotted. Please check the input object.")
})



# 4. Heatmap of Top 100 Variable Genes --------------------------------------

# Identify top 100 most variable genes
top100_count <- gene_count %>%
  rownames_to_column("symbol") %>%
  mutate(variance = apply(across(where(is.numeric)), 1, var)) %>%
  arrange(desc(variance)) %>%
  slice_head(n = 100) %>%
  column_to_rownames("symbol") %>%
  dplyr::select(-variance) %>%
  as.matrix()

# Create annotation
col <- colnames(top100_count)
treatment <- factor(gsub("[0-9]", "", col), levels = unique(sample_info$condition))
ann <- list(treatment = sample_color_list)
ha <- HeatmapAnnotation(treatment = treatment, col = ann)

# Z-score normalization by row
mat_scale <- top100_count %>%
  t() %>% scale(scale = TRUE) %>% t() %>% as.matrix() %>% na.omit()

# Save heatmap
png("02_figures/Top100 high-variance genes heatmap.png", width = 800, height = 1500, res = 100)
ComplexHeatmap::Heatmap(
  mat_scale,
  top_annotation = ha,
  cluster_columns = FALSE,
  show_row_names = TRUE,
  show_column_names = TRUE,
  row_title = "",
  name = "Z-score",
  col = colorRampPalette(c("#4575B4", "#F7F7F7", "#D73027"))(100)
)
dev.off()
message("Top 100 variable gene heatmap saved as 'Top100 high-variance genes heatmap.png'.")


message("====== All analyses completed in deseq2.R ======")