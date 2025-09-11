rule fastp:
    input:
        r1 = f"{DATA_DIR}/{{sample}}_R1.fastq.gz",
        r2 = f"{DATA_DIR}/{{sample}}_R2.fastq.gz"
    output:
        r1 = f"{OUTPUT_DIR}/{{sample}}_R1.trim.fastq.gz",
        r2 = f"{OUTPUT_DIR}/{{sample}}_R2.trim.fastq.gz",
        html = f"{OUTPUT_DIR}/{{sample}}.fastp.html",
        json = f"{OUTPUT_DIR}/{{sample}}.fastp.json"
    threads: 4
    log:
        f"{OUTPUT_DIR}/{{sample}}.log"
    shell:
        """
        fastp \
            -i {input.r1} -I {input.r2} \
            -o {output.r1} -O {output.r2} \
            --html {output.html} \
            --json {output.json} \
            --thread {threads} \
            &> {log}
        """
