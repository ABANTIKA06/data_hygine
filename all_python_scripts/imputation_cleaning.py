import pandas as pd
import numpy as np

# 1. Load the dataset from Phase 4
df = pd.read_csv("business_rules_cleaned_df.csv")
print("Total Records:", len(df))
print("Missing Values Before Imputation:")
print(df.isna().sum(), "\n")

# 2. Impute Categorical & Discrete Columns using Mode (Most Frequent Value)

# Country & Gender (Categorical Strings)
country_mode = df['country'].mode()[0]
gender_mode = df['gender'].mode()[0]
print("Country Mode:", country_mode)
print("Gender Mode:", gender_mode)

df['country'] = df['country'].fillna(country_mode)
df['gender'] = df['gender'].fillna(gender_mode)

# Discrete and Binary Flags (Products, Credit Card, Active Member)
products_mode = df['products_number'].mode()[0]
credit_card_mode = df['credit_card'].mode()[0]
active_member_mode = df['active_member'].mode()[0]

print("Products Number Mode:", products_mode)
print("Credit Card Mode:", credit_card_mode)
print("Active Member Mode:", active_member_mode)

df['products_number'] = df['products_number'].fillna(products_mode)
df['credit_card'] = df['credit_card'].fillna(credit_card_mode)
df['active_member'] = df['active_member'].fillna(active_member_mode)

# 3. Impute Continuous Numerical Columns using Median

# Skewed & Continuous Columns: Median is robust against remaining edge cases
credit_score_median = round(df['credit_score'].median(), 0)
age_median = round(df['age'].median(), 0)
tenure_median = round(df['tenure'].median(), 0)
balance_median = round(df['balance'].median(), 2)

print("Credit Score Median:", credit_score_median)
print("Age Median:", age_median)
print("Tenure Median:", tenure_median)
print("Balance Median:", balance_median)

df['credit_score'] = df['credit_score'].fillna(credit_score_median)
df['age'] = df['age'].fillna(age_median)
df['tenure'] = df['tenure'].fillna(tenure_median)
df['balance'] = df['balance'].fillna(balance_median)

# 4. Verify Missing Values After Imputation
print("\n=== Missing Values After Imputation ===")
print(df.isna().sum())

# 5. Summary Statistics
print(df.describe().round(2))

# 6. Save the final cleaned DataFrame
output_path = "imputed_cleaned_df.csv"
df.to_csv(output_path, index=False)
print("Dataframe is cleaned using imputation on Nan values", output_path)