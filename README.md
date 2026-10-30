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
│   └── clean_all.py                 # Unified end-to-end data hygiene pipeline
├── original_data/                   # Raw input datasets
├── verification_cleared.csv         # Final verified cleaned dataset (10,000 records)
├── data_cleaning_roadmap.md         # Detailed pipeline documentation
└── imputation_interview_cheatsheet.md
```

## 🚀 Getting Started
```bash
# Clone the repository
git clone git@github.com:ABANTIKA06/data_hygine.git
cd data_hygine

# Run the unified cleaning pipeline script
python3 all_python_scripts/clean_all.py
```
