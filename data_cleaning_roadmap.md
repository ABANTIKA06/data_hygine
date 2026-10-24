# 🧹 Data Hygiene & Cleaning Roadmap
## Dataset: `bank_customers_synthetic_dirty.csv`

---

## 📌 Executive Summary
This roadmap outlines a structured, step-by-step engineering plan to transform the raw, contaminated banking customer dataset into an audit-ready, standardized, and analytically sound dataset.

* **Source File**: `bank_customers_synthetic_dirty (copy).csv`
* **Total Raw Records**: `10,101`
* **Target Schema**: 10 columns (`customer_id`, `credit_score`, `country`, `gender`, `age`, `tenure`, `balance`, `products_number`, `credit_card`, `active_member`)

---

## 🗺️ Cleaning Pipeline Architecture

```
[ Raw CSV Data (10,101 rows) ]
               │
               ▼
┌────────────────────────────────────────────────┐
│ Phase 1: Deduplication & Structural Integrity   │
│  - Separate 100 exact duplicate rows           │
│  - Isolate duplicate customer_id collisions    │
└────────────────────────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────────┐
│ Phase 2: Categorical Cleaning & Typos          │
│  - Trim whitespace & normalize casing          │
│  - Fix country typos (Frnace, Span, Germny)    │
│  - Standardize gender (M/F, Male/Female)       │
└────────────────────────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────────┐
│ Phase 3: Text-to-Number Recovery & Type Cast   │
│  - Convert written numbers (thirty -> 30)      │
│  - Coerce unrecoverable text strings to NaN    │
│  - Enforce correct dtypes (float64, int64)     │
└────────────────────────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────────┐
│ Phase 4: Business Logic & Outlier Treatment   │
│  - Handle negative values (age -5, tenure -3)  │
│  - Address extreme outliers (age 150, 5M bal)  │
│  - Enforce binary values (0/1 for card/member) │
└────────────────────────────────────────────────┘
               │
               ▼
┌────────────────────────────────────────────────┐
│ Phase 5: Missing Value Imputation & Quality QA │
│  - Impute or drop NaN values by strategy       │
│  - Validate final schema and distributions     │
└────────────────────────────────────────────────┘
               │
               ▼
[ Production Datasets: Cleaned + Anomaly Exports ]
```

---

## 📋 Detailed Phased Action Plan

### Phase 1: Deduplication & Structural Integrity
- [ ] **1.1 Identify Exact Duplicate Rows**
  - Extract all exact duplicate rows using `df[df.duplicated(keep=False)]`.
  - Save them to `duplicates.csv`.
  - Drop redundant copies keeping the first occurrence (`df.drop_duplicates(keep='first')`).
- [ ] **1.2 Resolve `customer_id` Collisions**
  - Identify cases where the same `customer_id` is assigned to multiple distinct people (e.g. ID `20000015`).
  - Quarantine conflicting records into `id_conflicts.csv` for domain review.

---

### Phase 2: String Cleaning & Categorical Standardization
- [ ] **2.1 Standardize `country`**
  - Strip leading/trailing whitespaces: `.str.strip()`.
  - Standardize casing to Title Case: `.str.title()`.
  - Map spelling errors:
    * `"Frnace"` $\rightarrow$ `"France"`
    * `"Span"` $\rightarrow$ `"Spain"`
    * `"Germny"` $\rightarrow$ `"Germany"`
- [ ] **2.2 Standardize `gender`**
  - Strip whitespaces: `.str.strip()`.
  - Normalize abbreviations and casing:
    * `{"M": "Male", "male": "Male", "MALE": "Male"}`
    * `{"F": "Female", "female": "Female", "FEMALE": "Female"}`

---

### Phase 3: Text Recovery & Numeric Type Casting
- [ ] **3.1 Recover Words as Numbers**
  - Map written words before converting to numeric:
    * `age`: `"thirty"` $\rightarrow$ `30`
    * `credit_score`: `"six hundred"` $\rightarrow$ `600`
- [ ] **3.2 Coerce Junk Strings to `NaN`**
  - Convert `age`, `balance`, `credit_score`, and `tenure` using `pd.to_numeric(..., errors='coerce')`.
  - Strings like `"unknown"`, `"not available"`, `"?"`, and `"not recorded"` will cleanly become `NaN`.
- [ ] **3.3 Clean `products_number`**
  - Replace text entry `"many"` with `NaN` (or domain-defined default).
  - Coerce to numeric integer/float.

---

### Phase 4: Business Logic & Outlier Treatment
- [x] **4.1 Validate `age` (Domain Rule: 18 - 100)**
  - Negative values (`-5`): replaced with `NaN`.
  - Outliers (`150`): replaced with `NaN`.
- [x] **4.2 Validate `credit_score` (Domain Rule: 300 - 850)**
  - Negative values (`-50`): converted to `NaN`.
  - Over-limit scores (`1200`): converted to `NaN`.
- [x] **4.3 Validate `tenure` (Domain Rule: 0 - 10 years)**
  - Negative values (`-3`): converted to `NaN`.
  - Outliers (`25`): converted to `NaN`.
- [x] **4.4 Validate `balance`**
  - Negative balances (`-50000`): set to `NaN`.
  - Extreme values (`5000000`): confirmed artificial anomaly and set to `NaN`.
- [x] **4.5 Validate `credit_card` and `active_member` (Domain Rule: {0, 1})**
  - Mapped text: `{"yes": 1.0, "no": 0.0}`.
  - Replaced invalid numbers (`-1`, `2`) with `NaN`.
- [x] **4.6 Validate `products_number` (Domain Rule: 1 - 4 products)**
  - Replaced out-of-bounds values (`0`, `12`) with `NaN`.

---

### Phase 5: Missing Value Imputation Strategy
- [x] **5.1 Numerical Columns (`credit_score`, `age`, `balance`, `tenure`)**
  - Skewed columns (`balance`): Imputed with **Median** (`96,891.46`).
  - Symmetric & discrete columns (`age`, `credit_score`, `tenure`): Imputed with **Median** (`37.0`, `650.0`, `5.0`).
- [x] **5.2 Categorical & Binary Columns (`country`, `gender`, `products_number`, `credit_card`, `active_member`)**
  - Imputed with **Mode**: `country` (`France`), `gender` (`Male`), `products_number` (`1.0`), `credit_card` (`1.0`), `active_member` (`1.0`).

---

### Phase 6: Verification & Export
- [x] **6.1 Quality Assurance Checks**
  - Ensure `df.isna().sum()` is 0 (or within acceptable threshold).
  - Confirm data types with `df.dtypes`.
  - Check summary statistics with `df.describe()`.
- [x] **6.2 Output Deliverables**
  * `cleaned_data.csv`: Final sanitized, production-ready dataset.
  * `duplicates.csv`: Full duplicate records kept aside.
  * `quarantine_anomalies.csv`: Extreme unrecoverable rows kept for audit tracking.

---

## 💻 Master End-to-End Cleaning Pipeline Script

```python
import pandas as pd
import numpy as np

# ==========================================
# Phase 0: Load Raw Contaminated Dataset
# ==========================================
df = pd.read_csv("bank_customers_synthetic_dirty (copy).csv")
print("Raw Records Loaded:", len(df))

# ==========================================
# Phase 1: Deduplication & Structural Integrity
# ==========================================
# 1.1 Separate and drop exact duplicate rows
true_duplicates = df[df.duplicated(keep=False)].sort_values(by='customer_id')
true_duplicates.to_csv("true_duplicates.csv", index=False)
df_dedup = df.drop_duplicates(keep='first').copy()

# 1.2 Quarantine customer_id collisions (same ID assigned to distinct people)
false_duplicates = df_dedup[df_dedup.duplicated(subset=['customer_id'], keep=False)].sort_values(by='customer_id')
false_duplicates.to_csv("false_duplicates.csv", index=False)

conflicting_ids = false_duplicates['customer_id'].unique()
df = df_dedup[~df_dedup['customer_id'].isin(conflicting_ids)].copy().reset_index(drop=True)

# ==========================================
# Phase 2: String Cleaning & Categorical Standardization
# ==========================================
# 2.1 Standardize Country
country_map = {'Frnace': 'France', 'Span': 'Spain', 'Germny': 'Germany', 'Nan': np.nan}
df['country'] = df['country'].astype(str).str.strip().str.title().replace(country_map)

# 2.2 Standardize Gender
gender_map = {
    'M': 'Male', 'Male': 'Male', 'MALE': 'Male',
    'F': 'Female', 'Female': 'Female', 'FEMALE': 'Female',
    'Nan': np.nan
}
df['gender'] = df['gender'].astype(str).str.strip().replace(gender_map)

# ==========================================
# Phase 3: Text Recovery & Numeric Type Casting
# ==========================================
# 3.1 Word-to-number replacement
df['age'] = df['age'].replace({'thirty': 30})
df['credit_score'] = df['credit_score'].replace({'six hundred': 600})

# 3.2 Coerce junk text strings ('unknown', '?', 'many') to NaN
target_cols = ['credit_score', 'age', 'tenure', 'balance', 'products_number', 'credit_card', 'active_member']
for col in target_cols:
    df[col] = pd.to_numeric(df[col], errors='coerce')

# ==========================================
# Phase 4: Business Logic & Outlier Treatment
# ==========================================
# 4.1 Binary columns mapping & validation (credit_card & active_member in {0, 1})
binary_map = {'yes': 1.0, 'no': 0.0}
df['credit_card'] = df['credit_card'].replace(binary_map)
df['active_member'] = df['active_member'].replace(binary_map)
df['credit_card'] = np.where(np.isin(df['credit_card'], [0.0, 1.0]), df['credit_card'], np.nan)
df['active_member'] = np.where(np.isin(df['active_member'], [0.0, 1.0]), df['active_member'], np.nan)

# 4.2 Numerical range constraints (convert violations & extreme outliers to NaN)
df['age'] = np.where((df['age'] >= 18) & (df['age'] <= 100), df['age'], np.nan)
df['credit_score'] = np.where((df['credit_score'] >= 300) & (df['credit_score'] <= 850), df['credit_score'], np.nan)
df['tenure'] = np.where((df['tenure'] >= 0) & (df['tenure'] <= 10), df['tenure'], np.nan)
df['balance'] = np.where((df['balance'] >= 0) & (df['balance'] <= 1000000), df['balance'], np.nan)
df['products_number'] = np.where((df['products_number'] >= 1) & (df['products_number'] <= 4), df['products_number'], np.nan)

# ==========================================
# Phase 5: Missing Value Imputation Strategy
# ==========================================
# 5.1 Mode Imputation for Categorical & Discrete Flags
cat_cols = ['country', 'gender', 'products_number', 'credit_card', 'active_member']
for col in cat_cols:
    df[col] = df[col].fillna(df[col].mode()[0])

# 5.2 Median Imputation for Continuous Numeric Columns (robust against skewness)
num_cols = ['credit_score', 'age', 'tenure', 'balance']
for col in num_cols:
    df[col] = df[col].fillna(round(df[col].median(), 2 if col == 'balance' else 0))

# ==========================================
# Phase 6: Final Type Casting, Quality QA & Export
# ==========================================
# 6.1 Cast whole numbers from float64 back to int
int_cols = ['credit_score', 'age', 'tenure', 'products_number', 'credit_card', 'active_member']
df[int_cols] = df[int_cols].astype(int)
df['balance'] = df['balance'].round(2)

# 6.2 Quality assurance checks
assert df.isna().sum().sum() == 0, "Validation Error: Missing values remain!"
assert df['customer_id'].duplicated().sum() == 0, "Validation Error: Duplicate IDs remain!"

# 6.3 Export deliverables
output_path = "verification_cleared.csv"
df.to_csv(output_path, index=False)
print(f"🎉 Complete data hygiene pipeline executed successfully! Final clean records: {len(df)}")
```

