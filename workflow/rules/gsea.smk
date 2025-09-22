rule run_deg_gsea_analysis:
    input:
        raw_counts = f"{RESULTS_DIR}/01_counts/raw_count.csv"
    output:
        flag = f"{RESULTS_DIR}/.deg_gsea_done.flag"
    params:
        r_script = "scripts/gsea.R",
        comparison = config["comparison"]
    log:
        f"{RESULTS_DIR}/run_deg_gsea_analysis.log"
    shell:
        """
        Rscript {params.r_script} {RESULTS_DIR} {params.comparison} > {log} 2>&1
        touch {output.flag} >> {log} 2>&1
        rm -f Rplots.pdf
        """