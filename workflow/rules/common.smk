import csv

DATA_DIR = config["data_dir"]
OUTPUT_DIR = config["output_dir"]

with open(config["samplesheet"]) as f:
    reader = csv.DictReader(f)
    SAMPLES = [row["sample_name"] for row in reader]