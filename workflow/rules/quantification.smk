rule run_kallisto:
    input:
        clean_fastq1 = f"{CLEAN_READ_DIR}/{{sample}}_R1_clean.fastq.gz",
        clean_fastq2 = f"{CLEAN_READ_DIR}/{{sample}}_R2_clean.fastq.gz"
    output:
        abundance_tsv = f"{KALLISTO_QUANT_DIR}/{{sample}}/abundance.tsv",
        kallisto_log = f"{KALLISTO_QUANT_DIR}/{{sample}}/kallisto.log"
    params:
        abundance = f"{KALLISTO_QUANT_DIR}/{{sample}}"
    conda:
        "../envs/main.yaml"
    shell:
        """
        kallisto quant --plaintext -i {TRANSCRIPTOME_INDEX} \
        -o {params.abundance} -t {THREADS} {input.clean_fastq1} {input.clean_fastq2} \
        2>&1 | tee {output.kallisto_log}
        """