rule run_edgeR_analysis:
    input:
        kallisto_results = expand(f"{KALLISTO_QUANT_DIR}/{{sample}}/abundance.tsv", sample=SAMPLES)
    output:
        raw_counts = f"{RESULTS_DIR}/01_counts/raw_count.csv",
        euclidean_heatmap = report(
            f"{RESULTS_DIR}/02_figures/Euclidean Distance.png",
            category="Euclidean Distance"
            ),
        heatmap = f"{RESULTS_DIR}/02_figures/Top100 high-variance genes heatmap.png",
        summary_table = directory(f"{RESULTS_DIR}/03_summary_table")
    log:
        f"{RESULTS_DIR}/run_edgeR_analysis.log"
    params:
        samplesheet = config["samplesheet"],
        comparison = config["comparison"]
    shell:
        """
        mkdir -p {RESULTS_DIR}
        chmod -R 775 results
        Rscript scripts/edger.R {RESULTS_DIR} {REFERENCES_DIR} {params.samplesheet} {params.comparison} > {log} 2>&1
        rm -f Rplots.pdf
        """