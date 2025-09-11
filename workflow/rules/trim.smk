rule fastp:
    input:
        r1 = f"{RAW_DATA_DIR}/{{sample}}_R1.fastq.gz",
        r2 = f"{RAW_DATA_DIR}/{{sample}}_R2.fastq.gz"
    output:
        r1 = f"{CLEAN_READ_DIR}/{{sample}}_R1_clean.fastq.gz",
        r2 = f"{CLEAN_READ_DIR}/{{sample}}_R2_clean.fastq.gz",
        html = f"{CLEAN_READ_DIR}/{{sample}}.fastp.html",
        json = f"{CLEAN_READ_DIR}/{{sample}}.fastp.json"
    threads: 4
    log:
        f"{CLEAN_READ_DIR}/{{sample}}.log"
    conda:
        "../envs/main.yaml"
    shell:
        """
        mkdir -p {CLEAN_READ_DIR}
        fastp \
            -i {input.r1} -I {input.r2} \
            -o {output.r1} -O {output.r2} \
            --html {output.html} \
            --json {output.json} \
            --thread {threads} \
            &> {log}
        """


rule run_fastqc:
    input:
        clean_fastq1 = f"{CLEAN_READ_DIR}/{{sample}}_R1_clean.fastq.gz",
        clean_fastq2 = f"{CLEAN_READ_DIR}/{{sample}}_R2_clean.fastq.gz"
    output:
        fastqc_report1 = f"{FASTQC_REPORTS}/{{sample}}_R1_clean_fastqc.html",
        fastqc_report2 = f"{FASTQC_REPORTS}/{{sample}}_R2_clean_fastqc.html",
        fastqc_log = f"{FASTQC_REPORTS}/{{sample}}_fastqc.log"
    conda:
        "../envs/main.yaml"
    shell:
        """
        mkdir -p {FASTQC_REPORTS}
        fastqc -o {FASTQC_REPORTS} \
        {input.clean_fastq1} {input.clean_fastq2} \
        2>&1 | tee {output.fastqc_log}
        """