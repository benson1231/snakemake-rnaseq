import csv

DATA_DIR = config["data_dir"]
CLEAN_READ_DIR = config["clean_reads_dir"]
FASTQC_REPORTS = config["fastqc_reports_dir"]
KALLISTO_QUANT_DIR= config["kallisto_quant_dir"]

with open(config["samplesheet"]) as f:
    reader = csv.DictReader(f)
    SAMPLES = [row["sample_name"] for row in reader]