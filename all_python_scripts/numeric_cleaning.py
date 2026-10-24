import pandas as pd
import numpy as np

# 1. Load the dataset from Phase 2
df = pd.read_csv("typo_cleaned_df.csv")
print(df)

# Word-to-number recovery
df['age'] = df['age'].replace({'thirty': 30})
df['credit_score'] = df['credit_score'].replace({'six hundred': 600})

# Coerce text to numeric & turn junk strings into NaN
target_cols = ['credit_score', 'age', 'tenure', 'balance', 'products_number']

for cols in target_cols:
    df[cols] = pd.to_numeric(df[cols], errors='coerce')

# Verify results
print("\nUpdated Data Types:\n", df[target_cols].dtypes)
print("\nMissing values introduced by coercion:\n", df[target_cols].isna().sum())

# Save the cleaned numeric data  
df.to_csv("numeric_cleaned_df.csv", index=False)
print("\n Saved output to numeric_cleaned_df.csv successfully!")

