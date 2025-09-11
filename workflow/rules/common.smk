import pandas as pd

DATA_DIR = config["data_dir"]
OUTPUT_DIR = config["output_dir"]

SAMPLES_DF = pd.read_csv(config["samplesheet"])
SAMPLES = list(SAMPLES_DF["sample_name"])