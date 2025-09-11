import csv
from collections import Counter

RAW_DATA_DIR = config["raw_data_dir"]
OUTPUT_DIR = config["output_dir"]
CLEAN_READ_DIR = config["clean_reads_dir"]
FASTQC_REPORTS = config["fastqc_reports_dir"]
KALLISTO_QUANT_DIR = config["kallisto_quant_dir"]
MULTIQC_REPORTS_DIR = config["multiqc_reports_dir"]
RESULTS_DIR = config["results_dir"]

REFERENCES_DIR = config["references_dir"]

# 讀樣本名稱
with open(config["samplesheet"]) as f:
    reader = csv.DictReader(f)
    SAMPLES = [row["sample_name"] for row in reader]

# 讀條件
with open(config["samplesheet"]) as f:
    reader = csv.DictReader(f)
    conditions = [row["condition"] for row in reader]

# 統計每個 condition 的樣本數
cond_counts = Counter(conditions)

# 判斷差異分析方法
if all(count >= 2 for count in cond_counts.values()):
    DIFF_EXPR_METHOD = "deseq2"
    include: "deseq2.smk"
else:
    DIFF_EXPR_METHOD = "edger"
    include: "edger.smk"
