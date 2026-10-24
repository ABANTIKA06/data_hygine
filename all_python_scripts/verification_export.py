import pandas as pd


# Loading the dataset
df = pd.read_csv("/home/abantika/Documents/abantika_projects/data hygine/imputed_cleaned_df.csv")
print("the number of rows existing:", len(df))
print(df)

# Convert whole number cols from float to integer
int_columns =["credit_score","age", "tenure","products_number", "credit_card", "active_member" ]
df[int_columns] = df[int_columns].astype(int)

# Balance is money, so it should be float only with 2 decimal places
df["balance"] = df["balance"].round(2)
print(df.dtypes)

# Quality Checks
#1. Ensure zero missing values remain
print("Check for any missing values if any:",df.isna().sum())
print("Total missing values across table:",df.isna().sum().sum())


# Check for duplicate customer id's
print("Number of duplicate id's:",df['customer_id'].duplicated().sum())

# # 3. Check ranges and valid values

print("Credit Score Range :", df['credit_score'].min(), "to", df['credit_score'].max())
print("Age Range          :", df['age'].min(), "to", df['age'].max())
print("Tenure Range       :", df['tenure'].min(), "to", df['tenure'].max())
print("Balance Range      :", df['balance'].min(), "to", df['balance'].max())
print("Products Range     :", df['products_number'].min(), "to", df['products_number'].max())
print("Credit Card values :", df['credit_card'].unique())
print("Active Member values:", df['active_member'].unique())
print("Countries present  :", df['country'].unique())
print("Genders present    :", df['gender'].unique())


 # Final summary stats
print("Final summary statistics:",df.describe())

 # Save the final audit report to csv
output_path = "verification_cleared.csv"
df.to_csv(output_path,index=False)
print("Successfully exported the final dataset to:",output_path)

