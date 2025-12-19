rule run_kallisto:
    input:
        clean_fastq1 = f"{CLEAN_READ_DIR}/{{sample}}_R1_clean.fastq.gz",
        clean_fastq2 = f"{CLEAN_READ_DIR}/{{sample}}_R2_clean.fastq.gz",
        idx = f"{REFERENCES_DIR}/transcriptome.idx"
    output:
        abundance_tsv = f"{KALLISTO_QUANT_DIR}/{{sample}}/abundance.tsv",
        kallisto_log = f"{KALLISTO_QUANT_DIR}/{{sample}}/kallisto.log"
    params:
        abundance = f"{KALLISTO_QUANT_DIR}/{{sample}}"
    threads: 4
    conda:
        "../envs/main.yaml"
    shell:
        """
        mkdir -p {KALLISTO_QUANT_DIR}
        kallisto quant --plaintext -i {input.idx} \
        -o {params.abundance} -t {threads} {input.clean_fastq1} {input.clean_fastq2} \
        2>&1 | tee {output.kallisto_log}
        """