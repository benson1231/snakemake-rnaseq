import sys
import csv
from collections import Counter

print("\n" + "="*60)
print("🔧 Loaded configuration parameters")
print("="*60)

# Print all config parameters nicely
for k, v in config.items():
    print(f"{k:15} : {v}")
    
print("\n" + "="*60)
print("🔍 Starting input file validation...")
print("="*60 + "\n")

# ----- validate config.yaml -----
required_keys = ["raw_data_dir", "output_dir", "references_dir", "samplesheet", "comparison"]
missing = [k for k in required_keys if k not in config]
if missing:
    sys.exit(f"❌ config.yaml is missing required keys: {missing}")

config_path = "config/config.yaml"
print(f"✅ config.yaml is valid → {config_path}")

# ----- validate samplesheet.csv -----
samplesheet_path = config.get("samplesheet", "config/samplesheet.csv")
with open(samplesheet_path, newline="") as f:
    reader = csv.DictReader(f)
    samples = list(reader)

required_cols = ["sample_number", "sample_name", "abbreviation_name", "condition", "color"]
missing = [c for c in required_cols if c not in reader.fieldnames]
if missing:
    sys.exit(f"❌ samplesheet.csv is missing required columns: {missing}")

# Row-level completeness check
for i, row in enumerate(samples, start=1):
    for col in required_cols:
        if row[col] is None or row[col].strip() == "":
            sys.exit(f"❌ samplesheet.csv row {i} is missing value for column '{col}'")

print(f"✅ samplesheet.csv has valid columns and complete rows → {samplesheet_path}")

# Extract SAMPLES and conditions
SAMPLES = [row["sample_name"] for row in samples]
conditions = [row["condition"] for row in samples]

# ----- validate comparison.csv -----
comparison_path = config.get("comparison", "config/comparison.csv")
with open(comparison_path, newline="") as f:
    reader = csv.DictReader(f)
    comparisons = list(reader)

required_cols = ["Number", "Treatment", "Control"]
missing = [c for c in required_cols if c not in reader.fieldnames]
if missing:
    sys.exit(f"❌ comparison.csv is missing required columns: {missing}")

# Row-level completeness check
for i, row in enumerate(comparisons, start=1):
    for col in required_cols:
        if row[col] is None or row[col].strip() == "":
            sys.exit(f"❌ comparison.csv row {i} is missing value for column '{col}'")

# Check Treatment/Control values exist in valid conditions
valid_conditions = set(conditions)
invalid = set()
for row in comparisons:
    if row["Treatment"] not in valid_conditions or row["Control"] not in valid_conditions:
        invalid.add((row["Treatment"], row["Control"]))
if invalid:
    sys.exit(f"❌ comparison.csv contains unknown conditions: {invalid}")

print(f"✅ comparison.csv has valid columns and complete rows → {comparison_path}")

# ----- replicate count & DEG method -----
cond_counts = Counter(conditions)
if all(count >= 2 for count in cond_counts.values()):
    DIFF_EXPR_METHOD = "deseq2"
    include: "deseq2.smk"
    print("👉 Each condition has ≥ 2 replicates → Using DESeq2")
else:
    DIFF_EXPR_METHOD = "edger"
    include: "edger.smk"
    print("👉 Some conditions have < 2 replicates → Using edgeR")

print("\n" + "="*60)
print("🎉 All input files are valid, workflow setup complete!")
print("="*60 + "\n")
