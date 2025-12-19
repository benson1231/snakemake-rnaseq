rule download_kb_ref:
    output:
        idx = f"{REFERENCES_DIR}/transcriptome.idx",
        t2g = f"{REFERENCES_DIR}/transcripts_to_genes.txt"
    params:
        species = config["species"]
    conda:
        "../envs/main.yaml"
    shell:
        """
        mkdir -p {REFERENCES_DIR}
        kb ref -d {params.species} \
            -i {output.idx} \
            -g {output.t2g}
        """


rule download_gtf:
    output:
        gtf = f"{REFERENCES_DIR}/Homo_sapiens.GRCh38.113.gtf.gz"
    shell:
        """
        mkdir -p {REFERENCES_DIR}
        wget -O {output.gtf} \
          ftp://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz
        """


rule parse_gtf:
    input:
        gtf = rules.download_gtf.output.gtf
    output:
        transcript_csv = f"{REFERENCES_DIR}/transcript_annotations_113.csv",
        gene_csv = f"{REFERENCES_DIR}/gene_annotations_113.csv"
    conda:
        "../envs/ref.yaml"
    shell:
        """
        Rscript scripts/parse_gtf.R {input.gtf} {output.transcript_csv} {output.gene_csv}
        """