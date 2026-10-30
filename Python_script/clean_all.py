import pandas as pd
import numpy as np

# 1. Load the raw dirty dataset
df = pd.read_csv("original_data/bank_customers_synthetic_dirty (copy).csv")
print("1. Raw records loaded:", len(df))

# 2. Fix spaces and resync customer_id sequence (rows 0 to 9,999)
df['country'] = df['country'].astype(str).str.strip()
df['gender'] = df['gender'].astype(str).str.strip()
df.loc[:9999, 'customer_id'] = 20000001 + df.iloc[:10000].index

# 3. Remove duplicates: true duplicates & ID collisions
df = df.drop_duplicates(keep='first')
df = df.drop_duplicates(subset=['customer_id'], keep='first').reset_index(drop=True)
print("2. Records after deduplication:", len(df))

# 4. Fix country and gender typos
country_typos = {'Frnace': 'France', 'Span': 'Spain', 'Germny': 'Germany', 'Nan': np.nan}
df['country'] = df['country'].str.title().replace(country_typos)

gender_mapping = {'M': 'Male', 'F': 'Female', 'Nan': np.nan}
df['gender'] = df['gender'].str.title().replace(gender_mapping)

# 5. Convert written words to numbers and coerce junk to NaN
df['age'] = df['age'].replace({'thirty': 30})
df['credit_score'] = df['credit_score'].replace({'six hundred': 600})

numeric_columns = ['credit_score', 'age', 'tenure', 'balance', 'products_number']
for col in numeric_columns:
    df[col] = pd.to_numeric(df[col], errors='coerce')

# 6. Apply business rules and valid domain ranges
binary_map = {'yes': 1, 'Yes': 1, 'no': 0, 'No': 0}
df['credit_card'] = pd.to_numeric(df['credit_card'].replace(binary_map), errors='coerce')
df['active_member'] = pd.to_numeric(df['active_member'].replace(binary_map), errors='coerce')
df['credit_card'] = np.where(df['credit_card'].isin([0, 1]), df['credit_card'], np.nan)
df['active_member'] = np.where(df['active_member'].isin([0, 1]), df['active_member'], np.nan)

df['age'] = np.where((df['age'] >= 18) & (df['age'] <= 100), df['age'], np.nan)
df['credit_score'] = np.where((df['credit_score'] >= 300) & (df['credit_score'] <= 850), df['credit_score'], np.nan)
df['tenure'] = np.where((df['tenure'] >= 0) & (df['tenure'] <= 10), df['tenure'], np.nan)
df['balance'] = np.where((df['balance'] >= 0) & (df['balance'] <= 1000000), df['balance'], np.nan)
df['products_number'] = np.where((df['products_number'] >= 1) & (df['products_number'] <= 4), df['products_number'], np.nan)

# 7. Fill missing values (Mode for categories, Median for numbers)
for col in ['country', 'gender', 'products_number', 'credit_card', 'active_member']:
    df[col] = df[col].fillna(df[col].mode()[0])

df['credit_score'] = df['credit_score'].fillna(round(df['credit_score'].median(), 0))
df['age'] = df['age'].fillna(round(df['age'].median(), 0))
df['tenure'] = df['tenure'].fillna(round(df['tenure'].median(), 0))
df['balance'] = df['balance'].fillna(round(df['balance'].median(), 2))

# 8. Set final data types (integers for whole numbers, 2 decimal places for balance)
df['customer_id'] = df['customer_id'].astype(int)
df['credit_score'] = df['credit_score'].astype(int)
df['age'] = df['age'].astype(int)
df['tenure'] = df['tenure'].astype(int)
df['products_number'] = df['products_number'].astype(int)
df['credit_card'] = df['credit_card'].astype(int)
df['active_member'] = df['active_member'].astype(int)
df['balance'] = df['balance'].round(2)

# 9. Save single clean dataset
output_file = "verification_cleared.csv"
df.to_csv(output_file, index=False)
print("3. Successfully saved final cleaned dataset to:", output_file)
print("4. Total clean rows:", len(df))
print("5. Last record (Row 10,000):")
print(df.iloc[9999])
