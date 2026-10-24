import pandas as pd
import numpy as np

# 1. Load the dataset from Phase 3
df = pd.read_csv("numeric_cleaned_df.csv")
print("Total Records:", len(df))
print("Columns:", list(df.columns), "\n")

# 2. Inspect Outliers & Violations Before Treatment
print("=== Anomaly Counts Detected ===")
age_anomalies = ((df['age'] < 18) | (df['age'] > 100)).sum()
cs_anomalies = ((df['credit_score'] < 300) | (df['credit_score'] > 850)).sum()
tenure_anomalies = ((df['tenure'] < 0) | (df['tenure'] > 10)).sum()
balance_anomalies = ((df['balance'] < 0) | (df['balance'] > 1000000)).sum()
products_anomalies = ((df['products_number'] < 1) | (df['products_number'] > 4)).sum()

print("Age violations (<18 or >100):", age_anomalies)
print("Credit Score violations (<300 or >850):", cs_anomalies)
print("Tenure violations (<0 or >10):", tenure_anomalies)
print("Balance violations (<0 or >1,000,000):", balance_anomalies)
print("Products Number violations (<1 or >4):", products_anomalies, "\n")

# 3. Clean Binary Columns: credit_card & active_member
print("=== Cleaning Binary Flags (credit_card & active_member) ===")
binary_text_map = {
    'yes': 1.0, 'Yes': 1.0, 'YES': 1.0,
    'no': 0.0, 'No': 0.0, 'NO': 0.0
}

# Map text values to numeric equivalents
df['credit_card'] = df['credit_card'].replace(binary_text_map)
df['active_member'] = df['active_member'].replace(binary_text_map)

# Coerce to numeric
df['credit_card'] = pd.to_numeric(df['credit_card'], errors='coerce')
df['active_member'] = pd.to_numeric(df['active_member'], errors='coerce')

# Check invalid values (-1, 2)
invalid_cc = ~df['credit_card'].isin([0.0, 1.0]) & df['credit_card'].notna()
invalid_am = ~df['active_member'].isin([0.0, 1.0]) & df['active_member'].notna()
print("Invalid credit_card values (-1, 2) set to NaN:", invalid_cc.sum())
print("Invalid active_member values (-1, 2) set to NaN:", invalid_am.sum())

# Enforce binary domain {0, 1} using NumPy (np.where & np.isin)
df['credit_card'] = np.where(np.isin(df['credit_card'], [0.0, 1.0]), df['credit_card'], np.nan)
df['active_member'] = np.where(np.isin(df['active_member'], [0.0, 1.0]), df['active_member'], np.nan)

# 4. Outlier Treatment & Business Rule Constraints using NumPy np.where
# Logic: np.where(valid_condition, keep_value, np.nan)
print("\n=== Applying Business Logic & Domain Constraints (NumPy np.where) ===")

# 4.1 Age: Bank accounts require adult customers (18 - 100)
df['age'] = np.where((df['age'] >= 18) & (df['age'] <= 100), df['age'], np.nan)

# 4.2 Credit Score: Standard FICO range (300 - 850)
df['credit_score'] = np.where((df['credit_score'] >= 300) & (df['credit_score'] <= 850), df['credit_score'], np.nan)

# 4.3 Tenure: Customer relationship duration (0 - 10 years)
df['tenure'] = np.where((df['tenure'] >= 0) & (df['tenure'] <= 10), df['tenure'], np.nan)

# 4.4 Balance: Account balance (remove negative balances & 5M entry errors)
df['balance'] = np.where((df['balance'] >= 0) & (df['balance'] <= 1000000), df['balance'], np.nan)

# 4.5 Products Number: Standard banking products held (1 - 4)
df['products_number'] = np.where((df['products_number'] >= 1) & (df['products_number'] <= 4), df['products_number'], np.nan)

# 5. Validation & Verification
print("\n=== Post-Treatment Statistical Summary ===")
numeric_cols = ['credit_score', 'age', 'tenure', 'balance', 'products_number', 'credit_card', 'active_member']
print(df[numeric_cols].describe().round(2))

print("\n=== Missing Values Pending Imputation (Phase 5) ===")
print(df.isna().sum())

# 6. Save Cleaned Output
output_path = "business_rules_cleaned_df.csv"
df.to_csv(output_path, index=False)
print("\nPhase 4 complete! Successfully exported cleaned dataset to:", output_path)