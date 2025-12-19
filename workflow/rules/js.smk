rule get_results_js:
    input:
        flag = f"{RESULTS_DIR}/.deg_gsea_done.flag"
    output:
        result_js = f"{RESULTS_DIR}/images.js"
    log:
        f"{RESULTS_DIR}/get_results_js.log"
    conda:
        "../envs/main.yaml"
    shell:
        """
        python scripts/generate_file_structure_json.py \
            --source {RESULTS_DIR} \
            --output {output.result_js} \
            > {log} 2>&1
        """