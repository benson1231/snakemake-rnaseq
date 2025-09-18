import csv
from collections import Counter

# Read sample names from the samplesheet (CSV).
# The "sample_name" column is expected to contain unique identifiers for each sample.
with open(config.get("samplesheet", "config/samplesheet.csv")) as f:
    reader = csv.DictReader(f)
    SAMPLES = [row["sample_name"] for row in reader]

# Read experimental conditions from the samplesheet.
# The "condition" column specifies the group or treatment each sample belongs to.
with open(config.get("samplesheet", "config/samplesheet.csv")) as f:
    reader = csv.DictReader(f)
    conditions = [row["condition"] for row in reader]

# Count the number of samples per condition.
# This helps determine if each group has sufficient replicates.
cond_counts = Counter(conditions)

# Decide which differential expression method to use:
# - If every condition has at least 2 replicates, use DESeq2 (requires replicates).
# - Otherwise, fall back to edgeR (can handle no-replicate designs).
if all(count >= 2 for count in cond_counts.values()):
    DIFF_EXPR_METHOD = "deseq2"
    include: "deseq2.smk"
else:
    DIFF_EXPR_METHOD = "edger"
    include: "edger.smk"