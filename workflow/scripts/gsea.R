# Load required libraries
library(dplyr)          # For data manipulation
library(tidyr)          # For data tidying
library(flextable)      # For creating and saving formatted tables
library(EnhancedVolcano) # For generating volcano plots
library(ggplot2)        # For creating MA plots and other visualizations
library(openxlsx)       # For creating and saving Excel files
library(readxl)         # For reading .xlsx files
library(flextable)      # For creating and saving formatted tables
library(EnhancedVolcano) # For generating volcano plots
library(ggplot2)        # For creating MA plots and other visualizations
library(openxlsx)       # For creating and saving Excel files
library(clusterProfiler)
library(enrichplot)
library(cowplot)
library(DOSE)
library(biomaRt)
library(ReactomePA)
library(DOSE)
library(pathview)


# Read command-line arguments ---------------------------------------------
args <- commandArgs(trailingOnly = TRUE)

# Ensure at least one argument is provided (data path)
if (length(args) < 2) {
  stop("Missing argument: Please provide the data path.")
}

# Assign data path
data_path <- args[1]
comparison_file <- args[2]


# if testing --------------------------------------------------------------
# data_path <- "/home/benson/project/RNAseq/test_edgeR"


# file path ---------------------------------------------------------------
output_path <- data_path


# Create output directory if it doesn't exist
if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE)


# Set default flextable style ---------------------------------------------
set_flextable_defaults(
  background.color = "white",
  font.color = "black"
)



# Locate all .xlsx result files from edgeR outputs ------------------------
file_list <- list.files(
  path = file.path(output_path, "03_summary_table"),
  pattern = "\\.xlsx$",
  full.names = TRUE
)

# Stop if no result files are found
if (length(file_list) == 0) {
  stop("No .xlsx files found in the '03_summary_table' directory!")
} else{
  message("Found ", length(file_list), " file(s).\n",paste(file_list, collapse = "\n"))
}



# Read all Excel result files into a named list ---------------------------
deg_table_list <- lapply(file_list, read_xlsx)

# Assign names to list elements based on cleaned file names
names(deg_table_list) <- file_list %>%
  basename() %>%
  sub("edger_result_(.*)\\.xlsx$", "\\1", .)

# Display final list names for verification
message("There are ", length(deg_table_list), " Comparison")
print(names(deg_table_list))

# Start capturing stdout
if (!file.exists(file.path(output_path, "03_summary_table/DEG_summary.txt"))) file.create(file.path(output_path, "03_summary_table/DEG_summary.txt"))
sink(file.path(output_path, "03_summary_table/DEG_summary.txt"), split = TRUE, append = TRUE)

# Iterate over each dataset in the list
for (i in names(deg_table_list)) {
  # Create a subdirectory for each comparison
  comparison_name <- i
  comparison_dir <- file.path(output_path, "04_pathway", comparison_name)
  if (!dir.exists(comparison_dir)) dir.create(comparison_dir)
  
  # Extract the current DEG table
  cat(" ->", i, "\n")
  res_df <- deg_table_list[[i]] %>% as.data.frame()
  
  # Perform differential expression analysis and add significance annotation
  res_df <- res_df %>%
    dplyr::filter(!is.na(symbol)) %>%  # Remove rows with missing symbols
    dplyr::mutate(
      Significance = case_when(
        p_value < 0.05 & log2FoldChange > 1 ~ "Upregulated",
        p_value < 0.05 & log2FoldChange < -1 ~ "Downregulated",
        TRUE ~ "Not significant"
      )
    ) %>%
    dplyr::arrange(desc(abs(log2FoldChange)))
  
  # Summarize DEG statistics
  summary_deg <- table(res_df$Significance)
  cat(" -> Upregulated: ", summary_deg["Upregulated"],
      "\n -> Downregulated: ", summary_deg["Downregulated"],
      "\n -> Not significant: ", summary_deg["Not significant"], "\n\n")
  
  # Extract top 100 upregulated and downregulated genes
  up_top100 <- res_df %>%
    dplyr::filter(Significance != "Not significant" & log2FoldChange >= 1) %>%
    dplyr::arrange(desc(log2FoldChange)) %>%
    head(100)
  
  down_top100 <- res_df %>%
    dplyr::filter(Significance != "Not significant" & log2FoldChange <= (-1)) %>%
    dplyr::arrange(log2FoldChange) %>%
    head(100)
  
  # Save the top 10 upregulated genes as an image
  up_top10_ft <- up_top100[1:10, ] %>% 
    dplyr::select(c("ensembl", "symbol", "log2FoldChange", "p_value", "Significance")) %>% 
    mutate(p_value = formatC(p_value, format = "e", digits = 2)) %>% 
    flextable()
  save_as_image(up_top10_ft, file.path(comparison_dir, paste0("top10_up_", comparison_name, ".png")))
  
  # Save the top 10 downregulated genes as an image
  down_top10_ft <- down_top100[1:10, ] %>% 
    dplyr::select(c("ensembl", "symbol", "log2FoldChange", "p_value", "Significance")) %>%
    mutate(p_value = formatC(p_value, format = "e", digits = 2)) %>% 
    flextable()
  save_as_image(down_top10_ft, file.path(comparison_dir, paste0("top10_down_", comparison_name, ".png")))
  
  # Create a new Excel workbook
  wb <- createWorkbook()
  
  # Add DEG results to a worksheet
  addWorksheet(wb, paste0("DEG_", comparison_name))
  writeData(wb, sheet = paste0("DEG_", comparison_name), x = res_df)
  
  # Add top 100 upregulated genes to another worksheet
  addWorksheet(wb, paste0("Up_", comparison_name))
  writeData(wb, sheet = paste0("Up_", comparison_name), x = up_top100)
  
  # Add top 100 downregulated genes to another worksheet
  addWorksheet(wb, paste0("Down_", comparison_name))
  writeData(wb, sheet = paste0("Down_", comparison_name), x = down_top100)
  # Save the workbook to an Excel file
  saveWorkbook(wb, file = file.path(comparison_dir, paste0("DEG_", comparison_name, ".xlsx")), overwrite = TRUE)
  
  # Generate a volcano plot
  EnhancedVolcano(
    res_df,
    lab = res_df$symbol,
    x = 'log2FoldChange',
    y = 'p_value',
    xlab = "Log2 Fold Change",
    ylab = "-Log10 P-Value",
    pCutoff = 0.05,
    FCcutoff = 1,
    title = paste0("Volcano Plot - ", comparison_name),
    col = c("grey30", "forestgreen", "royalblue", "red2"),
    legendPosition = "right"
  )
  ggsave(file.path(comparison_dir, paste0("Volcano_plot_", comparison_name, ".png")), width = 12, height = 12)
  
  # Generate an MA plot
  if ("baseMean" %in% colnames(res_df)) {
    res_df$ma_x_axis <- log10(res_df$baseMean + 1)
    x_label <- "log10(baseMean + 1)"
  } else if ("logCPM" %in% colnames(res_df)) {
    res_df$ma_x_axis <- res_df$logCPM
    x_label <- "logCPM"
  } else {
    stop("Neither 'baseMean' nor 'logCPM' found in res_df.")
  }
  
  ggplot(res_df, aes(x = ma_x_axis, y = log2FoldChange, color = Significance)) +
    geom_point(alpha = 0.6, size = 1) +
    scale_color_manual(values = c("Upregulated" = "#D73027",
                                  "Downregulated" = "#4575B4",
                                  "Not significant" = "grey20"), name = "") +
    geom_hline(yintercept = c(1, -1), linetype = "dashed", color = "black", linewidth = 0.5) +
    labs(title = paste0("MA Plot - ", comparison_name),
         x = x_label,
         y = "log2FC") +
    theme_minimal() +
    theme(legend.position = "top")
  ggsave(file.path(comparison_dir, paste0("MA_plot_", comparison_name, ".png")), width = 8, height = 6)
}

# Stop capturing stdout
sink()

cat("All DEG results and plots saved in ", file.path(output_path, "03_summary_table"), "\n")

# Check if any .xlsx files exist
if (length(file_list) == 0) {
  stop("No .xlsx files found in the specified directory!")
}
# Read all .xlsx files into a list
deg_table_list <- lapply(file_list, read_xlsx)
# Assign names to the list elements based on file names
names(deg_table_list) <- basename(file_list)
# Extract meaningful parts from file names
names(deg_table_list) <- sub("edger_result_(.*)\\.xlsx$", "\\1", names(deg_table_list))
# Display the processed names
print(names(deg_table_list))

### Set
# Read experimental comparisons from Excel --------------------------------
comparisons <- readr::read_csv(comparison_file) %>% 
  dplyr::mutate(Comparison = paste0(Treatment, "_vs_", Control)) %>%  # Generate comparison names
  dplyr::select(c("Comparison", "Treatment", "Control"))

for (Comparison_group_num in seq_along(deg_table_list)) {
  print(comparisons$Comparison[Comparison_group_num])
  res_df <- deg_table_list[[comparisons$Comparison[Comparison_group_num]]]
  Comparison_group <- comparisons$Comparison[Comparison_group_num]
  
  # GSEA in GO --------------------------------------------------------------------
  if (!dir.exists(file.path(output_path, "04_pathway",Comparison_group, "GSEA"))) dir.create(file.path(output_path, "04_pathway",Comparison_group, "GSEA"), recursive = TRUE)
  
  organism_for_GSEA <- "org.Hs.eg.db"
  
  # get gene list
  ens <- res_df %>% 
    dplyr::select(c("log2FoldChange","ensembl")) %>% 
    aggregate(log2FoldChange ~ ensembl, FUN = mean)
  # $csv file's colume namm of log2 fold change
  original_gene_list <- ens$log2FoldChange
  # $csv file's colume namm of ENSEMBL ID 
  names(original_gene_list) <- ens$ensembl
  # omit any NA values and sort the list in decreasing order
  gsea_gene_list <- na.omit(original_gene_list) %>% 
    sort(., decreasing = TRUE)
  gsea_gene_list <- gsea_gene_list[!is.na(names(gsea_gene_list))]
  
  #run GSEA
  gse <- gseGO(geneList = gsea_gene_list, 
               ont = "ALL", 
               keyType = "ENSEMBL", 
               nPerm = 10000, 
               minGSSize = 3, 
               maxGSSize = 800, 
               pvalueCutoff = 0.05, 
               verbose = TRUE, 
               OrgDb = organism_for_GSEA, 
               pAdjustMethod = "none")
  
  # dot plot
  tryCatch({
    dotplot(gse, showCategory = 10, split = ".sign", label_format=50) + facet_grid(.~.sign)
    ggsave(file.path(output_path, "04_pathway", Comparison_group, "GSEA","GSEA_GO_dotPlot.png"), width = 10, height = 10)
  }, error = function(e) {
    cat(" -> ERROR: GSEA GO dotPlot failed\n")
  })

  # gsea plot
  tryCatch({
    p <- enrichplot::gseaplot2(gse, geneSetID = 1, title = gse$Description[1], color = "red")
    print(p)
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "GSEA","GSEA_GO_gseaPlot.png"), width = 6, height = 6)
  }, error = function(e) {
    cat(" -> ERROR: GSEA GO Plot failed\n")
  })

  # categorySize can be either 'pvalue' or 'geneNum'
  tryCatch({
    cat <- DOSE::setReadable(gse, "org.Hs.eg.db", keyType = "ENSEMBL")  # mapping geneID to gene Symbol
    cnetplot(cat, categorySize = "pvalue", showCategory = 3,
           color.params = list(foldChange = gse@geneList))
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "GSEA","GSEA_GO_cnetPlot.png"), width = 12, height = 12)
  }, error = function(e) {
    cat(" -> ERROR: GSEA GO CnetPlot failed\n")
  })
  

  # Enrichment map(gse)
  tryCatch({
    Enrichment_map_gsea <- pairwise_termsim(gse)
    emapplot(Enrichment_map_gsea)
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "GSEA","GSEA_GO_enrichmentPlot.png"), width = 12, height = 12)
  }, error = function(e) {
    cat(" -> ERROR: GSEA GO EnrichmentPlot failed\n")
  })

  # GSEA in KEGG --------------------------------------------------------------------
  if (!dir.exists(file.path(output_path, "04_pathway",Comparison_group, "KEGG"))) dir.create(file.path(output_path, "04_pathway",Comparison_group, "KEGG"), recursive = TRUE)

  organism_for_KEGG <- "hsa"

  enz <- res_df %>%
    dplyr::select(c("log2FoldChange","entrez")) %>%
    aggregate(log2FoldChange ~ entrez, FUN = mean)
  # selcet log2FC value
  kegg_gene_list <- enz$log2FoldChange
  # Name vector with ENTREZ ids
  names(kegg_gene_list) <- enz$entrez
  # omit any NA values and sort the list in decreasing order
  kegg_gene_list<- na.omit(kegg_gene_list) %>%
    sort(., decreasing = TRUE)
  kegg_gene_list <- kegg_gene_list[!is.na(names(kegg_gene_list))]

  # Run KEGG
  keg <- gseKEGG(geneList     = kegg_gene_list,
                 organism     = organism_for_KEGG,
                 nPerm        = 10000,
                 minGSSize    = 3,
                 maxGSSize    = 800,
                 pvalueCutoff = 0.05,
                 pAdjustMethod = "none",
                 keyType       = "ncbi-geneid")

  saveRDS(keg, file.path(output_path, "04_pathway", Comparison_group, "KEGG/KEGG.rds"))

  # dotplot
  tryCatch({
    dotplot(keg, showCategory = 10, title = "Enriched Pathways" , split=".sign") +
      facet_grid(.~.sign)
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "KEGG","GSEA_KEGG_dotPlot.png"), width = 10, height = 10)
  }, error = function(e) {
    cat(" -> ERROR: GSEA KEGG Dotplot failed\n")
  })

  # GSEA Plot
  tryCatch({
    p <- enrichplot::gseaplot2(keg, geneSetID = 1, title = keg@result$Description[1], color = "red")
    print(p)
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "KEGG","GSEA_KEGG_gseaPlot.png"), width = 6, height = 6)
  }, error = function(e) {
    cat(" -> ERROR: GSEA KEGG GSEAplot failed\n")
  })
  
  # Gene-Concept Network
  tryCatch({
    net <- DOSE::setReadable(keg, 'org.Hs.eg.db', 'ENTREZID')
    cnetplot(net, categorySize="pvalue", showCategory = 3,
           color.params = list(foldChange = keg@geneList))
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "KEGG","GSEA_KEGG_cnetPlot.png"), width = 12, height = 12)
  }, error = function(e) {
    cat(" -> ERROR: GSEA KEGG cnetPlot failed\n")
  })
  

  # Encrichment map
  tryCatch({
    kmat <- enrichplot::pairwise_termsim(keg)
    emapplot(kmat)
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "KEGG","GSEA_KEGG_enrichmentPlot.png"), width = 12, height = 12)
  }, error = function(e) {
    cat(" -> ERROR: GSEA KEGG EnrichmentPlot failed\n")
  })

  # Tree plot
  tryCatch({
    treeplot(kmat, cluster.params = list(method = "average"))
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "KEGG","GSEA_KEGG_treePlot.png"), width = 10, height = 10)
  }, error = function(e) {
    cat(" -> ERROR: GSEA KEGG Tree plot failed\n")
  })
  

  # pathview ----------------------------------------------------------------
  if (!dir.exists(file.path(output_path, "04_pathway",Comparison_group, "KEGG/pathway/information"))) dir.create(file.path(output_path, "04_pathway",Comparison_group, "KEGG/pathway/information"), recursive = T)

  # draw top 3 KEGG pathway genes
  flag <- 0
  kegg_path_num <- min(3, length(keg@result$ID))

  # 定義輸出資料夾
  kegg_outdir <- file.path(output_path, "04_pathway", Comparison_group, "KEGG/pathway")
  info_dir    <- file.path(kegg_outdir, "information")
  dir.create(kegg_outdir, recursive = TRUE, showWarnings = FALSE)
  dir.create(info_dir, recursive = TRUE, showWarnings = FALSE)

  for (kegg_pathway_id in keg@result$ID[1:kegg_path_num]) {
    tryCatch({
      flag <- flag + 1
      
      # 直接在輸出資料夾執行 pathview
      pv.out <- pathview(
        gene.data   = keg@geneList,
        pathway.id  = kegg_pathway_id,
        kegg.dir    = info_dir,        # KGML 會放在這裡
        species     = "hsa",
        kegg.native = TRUE,
        out.suffix  = paste0("No", flag)
      )
      
      # 把生成的圖檔移到 kegg_outdir
      generated_files <- list.files(getwd(), pattern = paste0(kegg_pathway_id, ".*"), full.names = TRUE)
      if (length(generated_files) > 0) {
        file.copy(generated_files, kegg_outdir, overwrite = TRUE)
        file.remove(generated_files)
      } else {
        message("No files generated for ", kegg_pathway_id)
      }
      
      print(paste("Finished:", kegg_pathway_id))
    }, error = function(e) {
      cat(" -> ERROR: pathview failed for", kegg_pathway_id, "\n")
    })
  }
  # pathview(gene.data = keg@geneList, pathway.id = "hsa04066", kegg.dir =  file.path(output_path, "04_pathway",Comparison_group, "KEGG/pathway/information"),,
  #          species = "hsa", kegg.native = T)


  # ORA in GO ---------------------------------------------------------------
  if (!dir.exists(file.path(output_path, "04_pathway",Comparison_group, "ORA/GO"))) dir.create(file.path(output_path, "04_pathway",Comparison_group, "ORA/GO"), recursive = TRUE)

  pvalueCutoff <- 0.05
  qvalueCutoff <- 0.2
  
  res_df <- res_df %>%
    dplyr::filter(!is.na(symbol)) %>%  # Remove rows with missing symbols
    dplyr::mutate(
      Significance = case_when(
        p_value < pvalueCutoff & log2FoldChange > 1 ~ "Upregulated",
        p_value < pvalueCutoff & log2FoldChange < -1 ~ "Downregulated",
        TRUE ~ "Not significant"
      )
    ) 
  deg_list <- res_df$entrez[res_df$Significance != "Not significant"]
  
  gsea_ont <- c("BP","CC","MF")

  ego_list <- list()
  for (ont in gsea_ont){
    cat(" -> Running ORA analysis in", ont, "\n")
    ego <- enrichGO(gene          = deg_list,
                    universe      = names(kegg_gene_list),
                    OrgDb         = "org.Hs.eg.db",
                    ont           = ont,
                    pAdjustMethod = "BH",
                    pvalueCutoff  = pvalueCutoff,
                    qvalueCutoff  = qvalueCutoff,
                    readable      = TRUE)

    ego_list[[ont]] <- ego

    cat(" -> plotting ~\n")
    tryCatch({
      barplot(ego, x = "GeneRatio")
      ggsave(file.path(output_path, "04_pathway",Comparison_group, "ORA/GO", paste0("ORA_", ont, "_barPlot.png")), width = 6, height = 6)
    }, error = function(e) cat(" -> ERROR: barPlot failed for", ont, "\n"))

    tryCatch({
      dotplot(ego)
      ggsave(file.path(output_path, "04_pathway",Comparison_group, "ORA/GO", paste0("ORA_", ont, "_dotPlot.png")), width = 8, height = 8)
    }, error = function(e) cat(" -> ERROR: dotPlot failed for", ont, "\n"))

    tryCatch({
      goplot(ego)
      ggsave(file.path(output_path, "04_pathway",Comparison_group, "ORA/GO", paste0("ORA_", ont, "_goPlot.png")), width = 12, height = 12)
    }, error = function(e) cat(" -> ERROR: goPlot failed for", ont, "\n"))
  }

  # ORA in KEGG ---------------------------------------------------------------
  if (!dir.exists(file.path(output_path, "04_pathway",Comparison_group, "ORA/KEGG"))) dir.create(file.path(output_path, "04_pathway",Comparison_group, "ORA/KEGG"), recursive = TRUE)

  kk <- enrichKEGG(gene         = deg_list,
                   organism     = 'hsa',
                   pvalueCutoff = pvalueCutoff,
                   qvalueCutoff = qvalueCutoff)

  tryCatch({
    barplot(kk, x = "GeneRatio")
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "ORA/KEGG", "ORA_KEGG_barPlot.png"), width = 6, height = 6)
  }, error = function(e) {
    cat(" -> ERROR: barPlot failed for KEGG\n")
  })

  tryCatch({
    dotplot(kk)
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "ORA/KEGG", "ORA_KEGG_dotPlot.png"), width = 8, height = 8)
  }, error = function(e) {
    cat(" -> ERROR: dotPlot failed for KEGG\n")
  })

  # browseKEGG(kk, 'hsa04110')


  # ORA in DO ---------------------------------------------------------------
  if (!dir.exists(file.path(output_path, "04_pathway",Comparison_group, "ORA/DO"))) dir.create(file.path(output_path, "04_pathway",Comparison_group, "ORA/DO"), recursive = TRUE)

  DO_result <- enrichDO(gene          = deg_list,
                        ont           = "HDO",
                        pvalueCutoff  = pvalueCutoff,
                        pAdjustMethod = "BH",
                        universe      = names(kegg_gene_list),
                        minGSSize     = 5,
                        maxGSSize     = 500,
                        qvalueCutoff  = qvalueCutoff,
                        readable      = TRUE)

  tryCatch({
    barplot(DO_result, x = "GeneRatio")
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "ORA/DO", "ORA_DO_barPlot.png"), width = 6, height = 6)
  }, error = function(e) {
    cat(" -> ERROR: barPlot failed for DO\n")
  })

  tryCatch({
    dotplot(DO_result)
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "ORA/DO", "ORA_DO_dotPlot.png"), width = 8, height = 8)
  }, error = function(e) {
    cat(" -> ERROR: dotPlot failed for DO\n")
  })



  # Disease enrichment analysis details -------------------------------------
  # ORA for the network of cancer gene
  # gene2 <- names(kegg_gene_list)[abs(kegg_gene_list) < 3]
  # ncg <- enrichNCG(gene2)
  # head(ncg)
  # dotplot(ncg)
  # barplot(ncg)
  #
  # # ORA for the disease gene network
  # dgn <- enrichDGN(deg_list)
  # head(dgn)
  # dotplot(dgn)
  # barplot(dgn)
  #
  # # ORA for the disease gene network(SNPs)
  # snp <- c("rs1401296", "rs9315050", "rs5498", "rs1524668", "rs147377392")
  # dgnv <- DOSE::enrichDGNv(snp)
  # head(dgnv)
  # dotplot(dgnv)
  # barplot(dgnv)


  # ORA in Reactome ---------------------------------------------------------------
  if (!dir.exists(file.path(output_path, "04_pathway",Comparison_group, "ORA/Reactome"))) dir.create(file.path(output_path, "04_pathway",Comparison_group, "ORA/Reactome"), recursive = TRUE)

  Reactome_result <- enrichPathway(gene         = deg_list,
                                   pvalueCutoff = pvalueCutoff,
                                   qvalueCutoff = qvalueCutoff,
                                   readable     = TRUE)

  tryCatch({
    barplot(Reactome_result, x = "GeneRatio")
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "ORA/Reactome", "ORA_Reactome_barPlot.png"), width = 6, height = 6)
  }, error = function(e) {
    cat(" -> ERROR: barPlot failed for Reactome\n")
  })

  tryCatch({
    dotplot(Reactome_result)
    ggsave(file.path(output_path, "04_pathway",Comparison_group, "ORA/Reactome", "ORA_Reactome_dotPlot.png"), width = 8, height = 8)
  }, error = function(e) {
    cat(" -> ERROR: dotPlot failed for Reactome\n")
  })


  # # Pathway Visualization
  # # change colors
  # red_white_blue_colors <- c("blue", "white", "red")
  # rwb_palette <- colorRampPalette(red_white_blue_colors)
  # n_colors <- 10
  # colors <- rwb_palette(n_colors)
  # viewPathway(Reactome_result@result$Description[1],
  #             readable = TRUE,
  #             foldChange = kegg_gene_list) +
  #   ggtitle(Reactome_result@result$Description[1]) +
  #   scale_color_gradientn(name = "fold change", colors=colors, na.value = "#E5C494")


  # output ------------------------------------------------------------------
  if(!dir.exists(file.path(output_path, "04_pathway",Comparison_group, "enrichment_results"))) dir.create(file.path(output_path, "04_pathway",Comparison_group, "enrichment_results"), recursive = TRUE)

  wb <- createWorkbook()

  result_list <- list(
    GSEA_GO_ALL = gse,
    GSEA_KEGG = keg,
    ORA_GO_BP = ego_list[["BP"]],
    ORA_GO_CC = ego_list[["CC"]],
    ORA_GO_MF = ego_list[["MF"]],
    ORA_KEGG =   kk,
    ORA_DO = DO_result,
    ORA_Reactome = Reactome_result
  )
  result_details <- c("GSEA_GO_ALL","GSEA_KEGG","ORA_GO_BP","ORA_GO_CC","ORA_GO_MF","ORA_KEGG","ORA_DO","ORA_Reactome")

  flag <- 1
  for(df in result_list){
    addWorksheet(wb, result_details[flag])
    writeData(wb, result_details[flag], df@result)
    addFilter(wb, result_details[flag], rows = 1, cols = 1:ncol(df))
    flag <- flag + 1
  }

  saveWorkbook(wb, file.path(output_path,"04_pathway",Comparison_group, "enrichment_results","enrichment_results_all_table.xlsx"), overwrite = TRUE)
  cat("Excel file saved as 'enrichment_results_all_table.xlsx' in\n", getwd(),"\n")

  set_flextable_defaults(
    background.color = "white",
    font.color = "black"
  )

  flag <- 1
  for (i in result_list) {
    df <- as.data.frame(i@result) %>%
      dplyr::arrange(abs(qvalue)) %>%
      head(10)

    optional_column <- "ONTOLOGY" 

    if (optional_column %in% colnames(df)) {
      selected_df <- df %>%
        dplyr::select(c(ID, ONTOLOGY, Description, NES, pvalue, qvalue))
    } else {
      selected_df <- df %>%
        dplyr::select(c(ID, Description, pvalue, qvalue))
    }

    ft <- flextable(selected_df) %>%
      theme_vanilla() %>%  
      autofit() 

    save_as_image(ft, file.path(output_path, "04_pathway",Comparison_group, "enrichment_results", paste0(result_details[flag], ".png")))

    flag <- flag + 1
  }
}

quit(status = 0, save = "no")