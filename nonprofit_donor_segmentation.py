import pandas as pd

# 1. Load the dataset (adjust the filename/path)
df = pd.read_csv("/Users/Lisa/Documents/GitHub/nonprofit/eo_ma.csv", low_memory=False)

# 2. View first 5 rows
print("First 5 rows:")
print(df.head(5))

# 3. Check data types for each column
print("\nColumn data types:")
print(df.dtypes)

# 4. Count missing values per column
missing_counts = df.isna().sum()
print("\nMissing values per column:")
print(missing_counts)

# 5. Flag rows where key outreach fields are missing
#    For example: NAME, STREET, CITY, ASSET_AMT should ideally all have values
df["needs_manual_review"] = (
    df["NAME"].isna()
    | df["STREET"].isna()
    | df["CITY"].isna()
    | df["ASSET_AMT"].isna()
)

total = len(df)
missing = df['NTEE_CD'].isna().sum()
percent_missing = missing / total * 100
print(f"{missing} of {total} missing → {percent_missing:.2f}%")

# -- Map NTEE letter to full mission name --
mission_map = {
    "A": "Arts, Culture & Humanities",
    "B": "Education",
    "C": "Environmental Quality & Protection",
    "D": "Animal-Related",
    "E": "Health – General & Rehabilitative",
    "F": "Mental Health & Crisis Intervention",
    "G": "Diseases, Disorders & Medical Disciplines",
    "H": "Medical Research",
    "I": "Crime & Legal-Related",
    "J": "Employment & Job-Related",
    "K": "Food, Agriculture & Nutrition",
    "L": "Housing & Shelter",
    "M": "Public Safety, Disaster Preparedness & Relief",
    "N": "Recreation, Sports & Leisure",
    "O": "Youth Development",
    "P": "Human Services – Multipurpose & Other",
    "Q": "International, Foreign Affairs & National Security",
    "R": "Civil Rights, Social Action & Advocacy",
    "S": "Community Improvement & Capacity Building",
    "T": "Philanthropy, Voluntarism & Grantmaking Foundations",
    "U": "Science & Technology Research & Services",
    "V": "Social Science Research & Services",
    "W": "Public & Societal Benefit – Multipurpose",
    "X": "Religion-Related, Spiritual Development",
    "Y": "Mutual/Membership Benefit Organizations",
    "Z": "Unknown / Unclassified"
}

# Create a new column using the first character of NTEE_CD
df["Mission"] = df["NTEE_CD"].str[0].map(mission_map)

# Keep only one clean 'Mission' column
if 'NTEE_CD' in df.columns:
    df['Mission_Code'] = df['NTEE_CD']
    df.drop(columns=['NTEE_CD'], inplace=True)

print(df.columns)

# 6. Filter for PACE-aligned missions
pace_focus = [
    "P",  # Human Services
    "S",  # Community Improvement
    "L",  # Housing & Shelter
    "K",  # Food, Agriculture & Nutrition
    "B"   # Education
]

pace_df = df[df["Mission"].isin([
    "Human Services – Multipurpose & Other",
    "Community Improvement & Capacity Building",
    "Housing & Shelter",
    "Food, Agriculture & Nutrition",
    "Education"
])]

print(f"{len(pace_df)} organizations align with PACE focus areas.")

# Summary statistics
total_orgs = len(df)
aligned = len(pace_df)
missing_mission = df['Mission'].isna().sum()
missing_ico = df['ICO'].isna().sum()

print(f"\nSummary:")
print(f"{aligned} out of {total_orgs} organizations align with PACE's mission.")
print(f"{missing_mission} out of {total_orgs} are missing mission codes and need further research.")
print(f"{missing_ico} out of {total_orgs} are missing 'In Care Of (ICO)' information.")

# Breakdown of alignment by mission category
print("\nPACE Mission Alignment Breakdown:")
print(pace_df['Mission'].value_counts())

# Financial overview for aligned organizations
financial_cols = ['NAME', 'CITY', 'STATE', 'ASSET_AMT', 'INCOME_AMT', 'REVENUE_AMT']
print("\nFinancial overview of PACE-aligned organizations:")
print(pace_df[financial_cols].head(10))

# Normalize city names and filter for Greater New Bedford area
greater_nb_towns = [
    "new bedford", "dartmouth", "fairhaven", "acushnet",
    "mattapoisett", "marion", "rochester", "westport", "wareham"
]

pace_df["CITY_CLEAN"] = pace_df["CITY"].astype(str).str.strip().str.lower()
pace_df = pace_df[pace_df["CITY_CLEAN"].isin(greater_nb_towns)]

# Now build and export contact list
contact_cols = [
    'NAME', 'STREET', 'CITY', 'STATE', 'ZIP',
    'ICO', 'Mission', 'ASSET_AMT', 'INCOME_AMT', 'REVENUE_AMT'
]

pace_contacts = pace_df[contact_cols].sort_values(by='CITY')

output_path = "pace_aligned_contacts.csv" # adjust the filename/path
pace_contacts.to_csv(output_path, index=False)

print(f"\nPACE-aligned contact list exported to: {output_path}")
print(pace_contacts.head(10))