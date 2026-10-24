# 💻 Pandas Imputation Reference Code (Interview Shortcut)

## 1. The Short Code (Vectorized in 2 Lines)

Instead of repeating `.fillna()` for every single column, show this shortcut in interviews:

```python
import pandas as pd

# Define column groups
num_cols = ['credit_score', 'age', 'tenure', 'balance']
cat_cols = ['country', 'gender', 'products_number', 'credit_card', 'active_member']

# 1. Fill all numeric columns with their respective medians in ONE line
df[num_cols] = df[num_cols].fillna(df[num_cols].median())

# 2. Fill all categorical/binary columns with their respective modes in ONE line
df[cat_cols] = df[cat_cols].fillna(df[cat_cols].mode().iloc[0])
```

---

## 2. How to Explain This Code to the Interviewer (Step-by-Step)

### Line 1: `df[num_cols].fillna(df[num_cols].median())`
* **What `df[num_cols].median()` does:**  
  Computes the median for each column in `num_cols` at the same time and returns a Pandas Series.
* **What `.fillna()` does:**  
  Matches each column by name and fills its `NaN` values with that column's median in a single vectorized step (fast and clean).

### Line 2: `df[cat_cols].fillna(df[cat_cols].mode().iloc[0])`
* **Why `.mode().iloc[0]`?**  
  In Pandas, `.mode()` returns a **DataFrame** (not a single number), because a column could technically have multiple modes (ties).  
  Using `.iloc[0]` takes the **first row**, which gives the top most frequent value for each column.
* **What `.fillna()` does:**  
  Replaces all `NaN` values in those columns with their respective most frequent category.

---

## 3. Dynamic 1-Liner Shortcut (No hardcoding column names)

```python
# Automatically fill ALL numeric columns with median
df = df.fillna(df.select_dtypes(include='number').median())

# Automatically fill ALL text/category columns with mode
for col in df.select_dtypes(include=['object', 'category']).columns:
    df[col] = df[col].fillna(df[col].mode()[0])
```
