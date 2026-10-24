# 🧹 Banking Customer Data Hygiene & Cleaning Pipeline

An end-to-end data cleaning, anomaly detection, and validation pipeline implemented in Python for contaminated banking customer records.

## 📌 Overview
This project processes dirty, synthetic banking data and transforms it into an audit-ready, standardized dataset.

### Pipeline Architecture
1. **Deduplication & Structural Integrity**: Separates exact duplicate rows and isolates ID collisions.
2. **Categorical Cleaning & Typos**: Trims whitespace, fixes country typographical errors, and normalizes gender values.
3. **Numeric Recovery & Type Casting**: Parses word-formatted numbers into numeric integers/floats and coerces invalid entries.
4. **Business Logic & Outlier Handling**: Corrects impossible values (negative age/tenure), flags extreme anomalies, and enforces binary flags.
5. **Missing Value Imputation**: Imputes missing values based on statistical distributions and exports verification datasets.

## 📂 Project Structure
```
├── all_python_scripts/
│   ├── duplicates_removal.py
│   ├── typo_cleaning.py
│   ├── numeric_cleaning.py
│   ├── business_rules_cleaning.py
│   ├── imputation_cleaning.py
│   └── verification_export.py
├── original_data/               # Raw input datasets
├── cleaned_data.csv             # Final verified cleaned dataset
├── data_cleaning_roadmap.md     # Detailed pipeline documentation
└── imputation_interview_cheatsheet.md
```

## 🚀 Getting Started
```bash
# Clone the repository
git clone git@github.com:ABANTIKA06/data_hygine.git
cd data_hygine

# Run the cleaning pipeline scripts
python3 all_python_scripts/duplicates_removal.py
python3 all_python_scripts/typo_cleaning.py
python3 all_python_scripts/numeric_cleaning.py
python3 all_python_scripts/business_rules_cleaning.py
python3 all_python_scripts/imputation_cleaning.py
python3 all_python_scripts/verification_export.py
```
