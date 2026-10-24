#import library
import pandas as pd
import numpy as np

# load the csv file
df = pd.read_csv('cleaned_dataframe.csv')
print(df)

# clean 'country' column(strip spaces, title case, fix misspellings)
df['country'] = df['country'].astype(str).str.strip().str.title()
country_typos = {
    'Frnace': 'France',
    'Span' : 'Spain',
    'Germny': 'Germany',
    'Nan': np.nan}

df['country'] = df['country'].replace(country_typos)

# clean 'gender'(strip spaces, standardize to Male/Female)

df['gender'] = df['gender'].astype(str).str.strip().str.title()
gender_mapping = {
    'M': 'Male',
    'F': 'Female',
    'Nan': np.nan
    }

df['gender']= df['gender'].replace(gender_mapping)

print("Changed country inconsistencies:",df['country'].unique())
print("Changed gender inconsistencies:",df['gender'].unique())

# Saving the cleaned data to a new file
df.to_csv("cleaned_dataframe_1.csv", index=False)
print("Saved the data to cleaned_dataframe_1.csv")