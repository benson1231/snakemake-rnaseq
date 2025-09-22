# Configuration Guide

This folder contains the configuration files required to run the RNA-seq analysis pipeline.

---

## 📂 Files in this folder

### 1. `config.yaml`

Defines global parameters for the workflow. These act as defaults but can be overridden dynamically using the `--config` flag when running Snakemake.

**Content overview:**

* `raw_data_dir`: Directory containing raw FASTQ data (default: `data`).
* `output_dir`: Root directory for analysis outputs (default: `results`).
* `references_dir`: Directory containing transcriptome reference files (default: `references`).
* `samplesheet`: Path to the `samplesheet.csv` file. This file lists all samples and experimental groups.
* `comparison`: Path to the `comparison.csv` file. This file defines treatment vs. control contrasts for differential analysis.
* `species`: Name of the species (e.g., `human`, `mouse`), used to determine reference genome/transcriptome resources.

---

### 2. `samplesheet.csv`

Describes all samples and their associated metadata. This file must contain the following columns:

* `sample_number` → Unique index number for each sample.
* `sample_name` → Identifier for the FASTQ file.
* `abbreviation_name` → Shortened name used in plots.
* `condition` → Experimental condition (must match entries in `comparison.csv`).
* `color` → Color code (hex or R color name) for plotting.

**Example content:**

```csv
sample_number,sample_name,abbreviation_name,condition,color
1,NC_22LWVNLT4,NC,NC,grey40
2,Bis-25-uM_22LWVNLT4,DEHP,DEHP,#4A90E2
3,NNK-10-uM_22LWVNLT4,NNK,NNK,#2C3E50
4,BaP-1-uM_22LWVNLT4,BaP,BaP,#A8CFCF
```

---

### 3. `comparison.csv`

Specifies treatment vs. control pairs for differential expression analysis. This file must contain the following columns:

* `Number` → Contrast index.
* `Treatment` → Experimental condition name.
* `Control` → Reference condition name.

**Example content:**

```csv
Number,Treatment,Control
1,DEHP,NC
2,NNK,NC
3,BaP,NC
```

---

## 🚀 Usage

By default, the pipeline will use these files inside the `config/` directory. You can override any parameter on the command line using `--config`. For example:

```bash
snakemake --cores 4 --use-conda \
  --config raw_data_dir="../.test/test_data" \
          output_dir="results" \
          references_dir="references" \
          samplesheet="../.test/config/samplesheet.csv" \
          comparison="../.test/config/comparison.csv" \
          species="mouse"
```

---

## 🧾 Notes

* Ensure all conditions listed in `comparison.csv` exist in the `condition` column of `samplesheet.csv`.
* Colors in `samplesheet.csv` will be directly applied to plots.
* All output files will be written under the directory specified in `output_dir`.
