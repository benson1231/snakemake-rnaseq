rule run_multiqc:
    input:
        fastqc_log = expand(f"{FASTQC_REPORTS}/{{sample}}_fastqc.log", sample=SAMPLES),
        kallisto_log = expand(f"{KALLISTO_QUANT_DIR}/{{sample}}/kallisto.log", sample=SAMPLES)
    output:
        multiqc_report = report(
        f"{MULTIQC_REPORTS_DIR}/multiqc_report.html",
            caption="../report/multiqc.rst",
            category="QC",
            subcategory="multiqc",
            labels={"sample": "multiqc_report.html"},
        ),
    conda:
        "../envs/main.yaml"
    log:
        f"{MULTIQC_REPORTS_DIR}/run_multiqc.log"
    shell:
        """
        mkdir -p {MULTIQC_REPORTS_DIR}
        multiqc {OUTPUT_DIR} \
            -o {MULTIQC_REPORTS_DIR} --force > {log} 2>&1
        """
