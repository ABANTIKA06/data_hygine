import pandas as pd 

# Loading the Dataset(CSV File)
df = pd.read_csv("bank_customers_synthetic_dirty (copy).csv")
print(df)

# Check for TRUE duplicates(Identical across all cols)
true_duplicates = df[df.duplicated(keep = False)].sort_values(by='customer_id')
print("True Duplicates:", len(true_duplicates))

# Drop redundant duplicate rows and keep only one copy of first occurence
df_non_redundant = df.drop_duplicates(keep ='first').copy()
print("Rows after removing true duplicates:",len(df_non_redundant))

# Check for False Duplicates (Same id but different data, id collision)
false_duplicates = df_non_redundant[df_non_redundant.duplicated(subset=["customer_id"], keep = False)].sort_values(by='customer_id')
print("False Duplicates:", len(false_duplicates))

# Quarantine the false duplicates
conflicting_ids = false_duplicates['customer_id'].unique()

# Exclude all conflicting customer IDs using the tilde(~) operator
df_clean =(
    df_non_redundant[~df_non_redundant['customer_id'].isin(conflicting_ids)].copy().reset_index(drop=True)
    )
print("Final clean Records:", len(df_clean))

# Export True Duplicates, False Duplicates, and Cleaned Data to CSV
true_duplicates.to_csv("true_duplicates.csv", index=False)
false_duplicates.to_csv("false_duplicates.csv", index=False)
df_clean.to_csv("dupli_cleaned_df.csv", index=False)
print("Saved true_duplicates, false_duplicates, and cleaned_dataframe successfully!")

