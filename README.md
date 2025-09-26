# snakemake-rnaseq

[![Tests](https://github.com/benson1231/snakemake-rnaseq/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/benson1231/snakemake-rnaseq/actions/workflows/main.yml)
![Docker](https://img.shields.io/badge/run%20in-docker-blue?logo=docker)
[![DockerHub](https://img.shields.io/badge/DockerHub-available-blue?logo=docker)](https://hub.docker.com/r/benson1231/bioc-rnaseq)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![GitHub release](https://img.shields.io/github/v/release/benson1231/snakemake-rnaseq)](https://github.com/benson1231/snakemake-rnaseq/releases)
[![License](https://img.shields.io/github/license/benson1231/snakemake-rnaseq)](./LICENSE)

---

## Usage

Run the test pipeline with testing config:

```bash
# run the workflow
docker compose run --rm rnaseq
snakemake --cores 4 --use-conda --configfile ../.test/config/config.yaml

# generate the report
snakemake --configfile ../.test/config/config.yaml --report results/report.html

# exit the container
exit
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

> **Note**: These paths act as defaults in `config.yaml` but can be overridden dynamically via CLI with `--config`.

---

## Configuration

See [config/README.md](config/README.md) for detailed instructions on configuring `config.yaml`, `samplesheet.csv`, and `comparison.csv`.

---

## Web

You can run the web interface directly with Docker, without installing Node.js or npm locally.


#### Copy results to web/public

Before starting the web server, copy the analysis results into the `web/public` directory.  
(Modify `results` if your output folder name is different.)

```bash
cp -r ./workflow/results/04_multiqc_reports ./web/public/04_multiqc_reports
cp -r ./workflow/results/05_results ./web/public/05_results
cp ./workflow/results/05_results/images.js ./web/src/assets/images.js
```

#### Run with Docker

```bash
docker run -it --rm \
  -p 5173:5173 \
  -v $(pwd)/web:/app \
  -w /app \
  node:20-alpine \
  sh -c "npm install && npm run dev -- --host"

# 'Ctrl + C' to exit
```

---

## Requirements

* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Snakemake ≥ 9.1.10](https://snakemake.github.io)
