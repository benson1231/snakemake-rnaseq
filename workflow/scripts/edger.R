# Load necessary libraries ------------------------------------------------
library(edgeR)
library(tximport)
library(tidyverse)
library(readxl)
library(openxlsx)
library(flextable)
library(ComplexHeatmap)
library(EnhancedVolcano)
library(RColorBrewer)
library(magrittr)
library(reshape2)



# Read command-line arguments ---------------------------------------------
args <- commandArgs(trailingOnly = TRUE)

# Ensure both 'data_path' and 'ref_path' are provided
if (length(args) < 4) {
  stop("Missing argument: Please provide both the 'data path' and 'reference file path'.")
}

# Assign arguments to path variables
data_path <- args[1]
ref_path <- args[2]
samplesheet_file <- args[3]
comparison_file <- args[4]

data_path
ref_path
samplesheet_file
comparison_file
getwd()

# if testing --------------------------------------------------------------
# data_path <- "/home/benson/git/snakemake-rnaseq/workflow/results"
# ref_path <- "/home/benson/git/snakemake-rnaseq/workflow/references"
# samplesheet_file <- "/home/benson/git/snakemake-rnaseq/.test/config/samplesheet.csv"
# comparison_file <-  "/home/benson/git/snakemake-rnaseq/.test/config/comparison.csv"



# file path ---------------------------------------------------------------
# project file
output_path <- data_path

# annotation file
transcript_annotations_path <- file.path(ref_path, "transcript_annotations_113.csv")
gene_annotations_path <- file.path(ref_path, "gene_annotations_113.csv")

# Create output directory if it doesn’t exist
if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE)


# add folders --------------------------------------------------------------
folders <- c("01_counts", "02_figures", "03_summary_table", "04_pathway")

for (folder in folders) {
  target_dir <- file.path(output_path, folder)
  if (!dir.exists(target_dir)) {
    dir.create(target_dir, recursive = TRUE)
    message("新建資料夾: ", normalizePath(target_dir))
  } else {
    message("已存在: ", normalizePath(target_dir))
  }
}
list.dirs(path = "results/05_results", recursive = FALSE)

# load file ---------------------------------------------------------------
# Read gene annotation file and extract gene_id and gene_name
gene_annotations <- readr::read_csv(gene_annotations_path)
ensembl_symbol_df <- gene_annotations %>%
  dplyr::select(gene_id, gene_name) %>%
  setNames(c("ensembl", "symbol"))
message("Loaded gene annotations from: ", gene_annotations_path,
        " (", nrow(gene_annotations), " records)")

# Read transcript annotation file and extract transcript-to-gene mapping
transcript_annotations <- readr::read_csv(transcript_annotations_path) %>%
  dplyr::select(transcript_id, gene_id)
message("Loaded transcript annotations from: ", transcript_annotations_path,
        " (", nrow(transcript_annotations), " records)")

# Load sample metadata from CSV
sample_info <- readr::read_csv(samplesheet_file) %>%
  mutate(row_name = sample_name) %>%               # Use sample_name as row names
  column_to_rownames("row_name")

message("Loaded sample metadata from: ", samplesheet_file,
        " (", nrow(sample_info), " samples)")

# Convert grouping columns to factors
sample_info$condition <- factor(sample_info$condition, levels = unique(sample_info$condition))
sample_info$abbreviation_name <- factor(sample_info$abbreviation_name, levels = unique(sample_info$abbreviation_name))
condition <- factor(sample_info$condition, levels = unique(sample_info$condition))
group <- factor(sample_info$condition)

# Preview sample information
print(head(sample_info))

# Load comparison table
comparison_info <- readr::read_csv(comparison_file)
message("Loaded comparison table from: ", comparison_file,
        " (", nrow(comparison_info), " comparisons)")

print(head(comparison_info))

# Set default flextable appearance: white background, black text
set_flextable_defaults(
  background.color = "white",
  font.color = "black"
)

# ========================================
# Save sample metadata as table image
# ========================================
info <- readr::read_csv(samplesheet_file)  %>%
  mutate(row_name = abbreviation_name) %>%
  column_to_rownames("row_name")

sample_info_ft <- flextable(info)  # Create flextable object
save_as_image(sample_info_ft, file.path(output_path, "02_figures/Sample information.png"))  # Save table as PNG
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
comparisons <- readr::read_csv(comparison_file) %>%
  dplyr::mutate(Comparison = paste0(Treatment, "_vs_", Control)) %>%  # Create combined label
  dplyr::select(Comparison, Treatment, Control)

# ========================================
# Save comparison table as image for reports or tracking
# ========================================
comparisons_ft <- flextable(comparisons)
save_as_image(comparisons_ft, file.path(output_path,"02_figures/Sample comparisons.png"))
message("Sample comparisons table saved as image: 'Sample comparisons.png'")



# Prepare Kallisto abundance file paths ----------------------------------
# Construct file paths for each sample's abundance.tsv
files <- file.path("results","03_kallisto_quant", sample_info$sample_name, "abundance.tsv")
names(files) <- sample_info$sample_name  # Name each file by sample
message("Loaded Kallisto abundance paths for ", length(files), " samples.")

print(files)

# Import Kallisto quantification results ----------------------------------
txi.kallisto <- tximport(
  files = files,
  type = "kallisto",
  tx2gene = transcript_annotations,  # Transcript-to-gene mapping
  txOut = FALSE,                  # Summarize to gene level
  ignoreTxVersion = TRUE
)

message("Imported gene-level expression matrix with ", 
        nrow(txi.kallisto$counts), " genes and ", 
        ncol(txi.kallisto$counts), " samples.")



# Prepare count matrix and group information ------------------------------
count_df <- txi.kallisto$counts

# save raw count
write.csv(count_df, file = file.path(output_path, "01_counts/raw_count.csv"))
message("Saved raw count matrix to 'raw_count.csv'")

# ========================================
# Sample name mapping
# ========================================
sample_name_map <- sample_info$abbreviation_name
names(sample_name_map) <- rownames(sample_info)

# ========================================
# Create DGEList object for edgeR analysis
# ========================================
dge_raw <- edgeR::DGEList(counts = count_df)
message("Created DGEList object with ", nrow(dge_raw), " genes and ", ncol(dge_raw), " samples.")

# ========================================
# Pre-filter genes based on CPM threshold
# ========================================
keep <- rowSums(cpm(dge_raw) >= 1) >= (ncol(dge_raw) / 2)
dge_filtered <- dge_raw[keep, , keep.lib.sizes = FALSE]  # Optional: recompute lib size
message("Filtered low-expression genes; retained ", sum(keep), " genes.")

# Normalize counts --------------------------------------------------------
dge <- calcNormFactors(dge_filtered, method = c("TMM"))  # Apply TMM normalization to account for library size
message("TMM normalization complete. Normalization factors estimated.")

# ========================================
# Raw log2 CPM (Before normalization)
# ========================================
log2_cpm_raw <- dge %>% 
  cpm(., log = FALSE, normalized.lib.sizes = FALSE) %>% 
  `+`(1) %>%
  log2() %>%
  set_colnames(sample_name_map[colnames(.)])

# ========================================
# Normalized counts → log2 CPM
# ========================================
log2_cpm_norm <- dge %>% 
  cpm(., log = FALSE, normalized.lib.sizes = TRUE) %>% 
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
ggsave(file.path(output_path, "02_figures/boxplot_log2CPM.png"), p, width = 10, height = 6)
message("Boxplot saved as 'boxplot_log2CPM.png'")

# ========================================
# Perform DE analysis and annotate results for each comparison
# ========================================

# Set dispersion manually (recommended when no biological replicates)
dge$common.dispersion <- 0.05
message("Common dispersion manually set to 0.05.")

# ========================================
# Create contrast matrix for group comparisons
# ========================================
message("Constructing contrast matrix for group comparisons...")

contrast_matrix <- matrix(0, nrow = length(levels(group)), ncol = nrow(comparisons),
                          dimnames = list(levels(group), comparisons$Comparison))

for (i in seq_len(nrow(comparisons))) {
  treatment_group <- comparisons$Treatment[i]
  control_group <- comparisons$Control[i]
  comparison_name <- comparisons$Comparison[i]
  
  contrast_matrix[treatment_group, comparison_name] <- 1
  contrast_matrix[control_group, comparison_name] <- -1
}

contrast_matrix <- as.data.frame(contrast_matrix)
message("Contrast matrix created with ", ncol(contrast_matrix), " comparisons.")
print(contrast_matrix)

# ========================================
# Initialize and build model design
# ========================================
message("Building design matrix for GLM fitting...")

design <- model.matrix(~ 0 + group)
colnames(design) <- levels(group)

message("Design matrix:")
print(design)

# ========================================
# Fit GLM
# ========================================
message("Fitting negative binomial GLM with common dispersion...")
fit <- glmFit(dge, design)
message("GLM fitting complete.")

# ========================================
# Run likelihood ratio tests
# ========================================
message("Running likelihood ratio tests for each contrast...")

lrt_results_list <- list()

for (i in seq_len(nrow(comparisons))) {
  comparison_name <- comparisons$Comparison[i]
  contrast_vector <- contrast_matrix[, comparison_name]
  
  message("Running LRT for comparison: ", comparison_name)
  lrt_result <- glmLRT(fit, contrast = contrast_vector)
  lrt_results_list[[comparison_name]] <- lrt_result
  message("LRT completed for: ", comparison_name)
}

message("All comparisons complete. Stored results for: ", paste(names(lrt_results_list), collapse = ", "))


# ========================================
# Annotate each LRT result with gene metadata
# ========================================
message("Starting annotation of DE results...")

annotated_results_list <- list()

for (comparison_name in names(lrt_results_list)) {
  
  message("Annotating result for comparison: ", comparison_name)
  
  # Extract full result table
  lrt_table <- topTags(lrt_results_list[[comparison_name]], n = Inf)$table %>%
    rownames_to_column(var = "gene_id")
  
  # Merge with annotation metadata
  annotated_result <- lrt_table %>%
    left_join(gene_annotations, by = "gene_id") %>%
    dplyr::select(
      gene_id, gene_name, logFC, logCPM, PValue,
      entrez_id, gene_biotype, start, end, length, strand
    ) %>%
    setNames(c(
      "ensembl", "symbol", "log2FoldChange", "logCPM", "p_value",
      "entrez", "biotype", "start", "end", "length", "strand"
    ))
  
  # Store
  annotated_results_list[[comparison_name]] <- annotated_result
  message("Annotation complete for: ", comparison_name, 
          " (", nrow(annotated_result), " genes)")
}

# ========================================
# Export annotated results to Excel
# ========================================
output_dir <- file.path(output_path, "03_summary_table")
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
  message("Created output directory: ", output_dir)
} else {
  message("Output directory already exists: ", output_dir)
}

message("Exporting annotated results to Excel...")

for (comparison_name in names(annotated_results_list)) {
  
  current_result <- annotated_results_list[[comparison_name]]
  
  wb <- createWorkbook()
  addWorksheet(wb, comparison_name)
  writeData(wb, sheet = comparison_name, x = current_result)
  addFilter(wb, sheet = comparison_name, rows = 1, cols = 1:ncol(current_result))
  setColWidths(wb, sheet = comparison_name, cols = 1:ncol(current_result), widths = "auto")
  
  output_file <- paste0("edger_result_", comparison_name, ".xlsx")
  saveWorkbook(wb, file = file.path(output_dir, output_file), overwrite = TRUE)
  
  message("Saved annotated edgeR result to: ", output_file)
}

message("All annotated results exported.")



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
png(file.path(output_path, "02_figures/Euclidean Distance.png"), width = 800, height = 700, res = 100)
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

  ggsave(file.path(output_path, "02_figures/PCA plot.png"), width = 7, height = 7)

}, error = function(e) {
  warning("PCA could not be performed or plotted. Please check the gene count matrix and sample size.")
})



# 3. MDS Plot ----------------------------------------------------------------

tryCatch({
  
  # Save MDS plot to PNG
  png(file.path(output_path, "02_figures/MDS plot.png"), width = 800, height = 700, res = 100)
  
  # Set plot margins and allow drawing outside the plot region
  par(mar = c(5, 4, 4, 6), xpd = NA)
  
  # Draw MDS plot (plotMDS does not automatically include a legend)
  plotMDS(dge,
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
png(file.path(output_path, "02_figures/Top100 high-variance genes heatmap.png"), width = 800, height = 1500, res = 100)
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


message("====== All analyses completed in edger.R ======")