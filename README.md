# snakemake-rnaseq

[![Tests](https://github.com/benson1231/snakemake-rnaseq/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/benson1231/snakemake-rnaseq/actions/workflows/main.yml)
[![Snakemake](https://img.shields.io/badge/snakemake-≥9.1.10-brightgreen.svg)](https://snakemake.github.io)

---

## Usage


Run the test pipeline with testing config:


```bash
docker compose run --rm rnaseq
snakemake --cores 4 --use-conda --configfile ../.test/config/config.yaml
```


Run the test pipeline by overriding config values via CLI:


```bash
snakemake --cores 4 --use-conda \
--config raw_data_dir="../.test/test_data" \
output_dir="results" \
references_dir="references" \
samplesheet="../.test/config/samplesheet.csv" \
comparison="../.test/config/comparison.csv"
```


> **Note**: These paths act as defaults in `config.yaml` but can be overridden dynamically via CLI with `--config`


---


## Configuration


Below is an example of the default `config.yaml` setup. These values should be adjusted based on your dataset and experimental design.


```yaml
# Directory containing raw FASTQ data.
raw_data_dir: "data"
# Root directory for analysis outputs.
output_dir: "results"
# Directory that will contain transcriptome reference files downloaded by the pipeline.
references_dir: "references"
# Path to the samplesheet (CSV file).
# - The pipeline uses this file to determine which samples to process and the corresponding FASTQ file locations.
samplesheet: config/samplesheet.csv
# Path to the comparison file (CSV file).
# - The pipeline will generate differential analysis results based on this configuration.
comparison: config/comparison.csv
```


### Example samplesheet.csv
```csv
sample_number,sample_name,abbreviation_name,condition,color
1,A_0uM,A,A,grey40
2,B_5uM,B,B,#4A90E2
3,C_10uM,C,C,#2C3E50
4,D_20uM,D,D,#A8CFCF
```

### Example comparison.csv
```csv
Number,Treatment,Control
1,B,A
2,C,A
3,D,A
```

> ⚠️ These CSV files must be customized based on your actual experimental design and available raw data.


---


## Requirements


* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Snakemake ≥ 9.1.10](https://snakemake.github.io)