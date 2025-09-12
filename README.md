# snakemake-rnaseq

[![Tests](https://github.com/benson1231/snakemake-rnaseq/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/benson1231/snakemake-rnaseq/actions/workflows/main.yml)
[![Snakemake](https://img.shields.io/badge/snakemake-≥9.1.10-brightgreen.svg)](https://snakemake.github.io)

---

🚧 **Under construction** 🚧

This repository contains a reproducible RNA-seq analysis pipeline built with [Snakemake](https://snakemake.github.io) and containerized using Docker Compose. It is designed to streamline preprocessing, quantification, QC, and downstream analysis steps.

## Usage

Clone the repository and enter the workflow directory:

```bash
cd workflow/
```

Run the container:

```bash
docker compose run --rm rnaseq
```

Execute the Snakemake pipeline with 16 cores and conda environments:

```bash
snakemake --cores 16 --use-conda
```

## Requirements

* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Snakemake ≥ 9.1.10](https://snakemake.github.io)

## Status

* ✅ GitHub Actions CI for testing
* 🚧 Pipeline under active development
