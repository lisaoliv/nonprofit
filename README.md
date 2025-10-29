# nonprofit

This repository contains data supporting outreach and fundraising analysis for Greater New Bedford, including Acushnet, Dartmouth, Fairhaven, Freetown, Marion, Mattapoisett, Rochester, and Wareham. The purpose is to identify prospective donors who may contribute more than $1,000 and to create a verified contact directory with accurate names, addresses, phone numbers, and emails.

**Dataset:** `eu_ma.csv`  
**Source:** [IRS Exempt Organizations Business Master File](https://www.irs.gov/charities-non-profits/exempt-organizations-business-master-file-extract-eo-bmf)

---

### VARIABLE DESCRIPTIONS

| Column Name | Code Name | Description |
|--------------|------------|-------------|
| EIN | Employer Identification Number | Nine-digit number assigned by the IRS to identify an organization’s account. |
| NAME | Primary Name of Organization |  |
| ICO | In Care of Name | The person (officer, director, etc.) to whose attention correspondence should be directed. |
| STREET | Street Address |  |
| CITY | City |  |
| STATE | State |  |
| ZIP | Zip Code |  |
| GROUP | Group Exemption Number |  |
| SUBSECTION | Subsection Code |  |
| AFFILIATION | Affiliation Code |  |
| CLASSIFICATION | Classification Code(s) |  |
| RULING | Ruling Date |  |
| DEDUCTIBILITY | Deductibility Code | Indicates if contributions are tax-deductible. (1 = Deductible; 2 = Not deductible; 4 = Deductible by treaty – foreign organizations.) |
| FOUNDATION | Foundation Code |  |
| ACTIVITY | Activity Codes |  |
| ORGANIZATION | Organization Code | Defines organization type: 1 = Corporation; 2 = Trust; 3 = Cooperative; 4 = Partnership; 5 = Association. |
| STATUS | Exempt Organization Status Code |  |
| TAX_PERIOD | Tax Period | Tax period of latest return filed (YYYYMM). |
| ASSET_CD | Asset Code | Book value of assets on most recent Form 990. ([See Asset/Income Code Table](#asset--income-code-table)) |
| INCOME_CD | Income Code | Total income on most recent Form 990. ([See Asset/Income Code Table](#asset--income-code-table)) |
| FILING_REQ_CD | Filing Requirement Code | Indicates the primary return(s) required. ([See Filing Requirement Code Table](#filing-requirement-code-table)) |
| PF_FILING_REQ_CD | PF Filing Requirement Code | Indicates private-foundation (grantmaker) status. Filing Form 990-PF corresponds to private foundations; Form 990 to public charities. |
| ACCT_PD | Accounting Period | Fiscal year-end month (MM). |
| ASSET_AMT | Asset Amount | Total assets reported at end of year. Form 990 → Part X Line 16(b); 990EZ → Part II Line 25(b); 990PF → Part II Line 16(b). |
| INCOME_AMT | Income Amount | Computed as revenue plus expense adjustments: 990 = L12 + L6b; 990EZ = L9 + L5b; 990PF = L10b + L12(A) + L1(G). |
| REVENUE_AMT | Form 990 Revenue Amount | Reported total revenue: 990 = L12; 990EZ = L9. |
| NTEE_CD | National Taxonomy of Exempt Entities Code |  |
| SORT_NAME | Sort Name | Secondary name line (if present). |

---

### ASSET / INCOME CODE TABLE

| # | Description ($) |
|---|-----------------|
| 0 | 0 |
| 1 | 1 to 9,999 |
| 2 | 10,000 to 24,999 |
| 3 | 25,000 to 99,999 |
| 4 | 100,000 to 499,999 |
| 5 | 500,000 to 999,999 |
| 6 | 1,000,000 to 4,999,999 |
| 7 | 5,000,000 to 9,999,999 |
| 8 | 10,000,000 to 49,999,999 |
| 9 | 50,000,000 or greater |

---

### FILING REQUIREMENT CODE TABLE

| # | Form Description |
|---|------------------|
| 01 | Form 990 or 990EZ (all others) |
| 02 | Form 990-N — income under $50,000 per year |
| 03 | Form 990 — group return |
| 04 | Form 990-BL — Black Lung Trusts |
| 06 | Not required to file (church) |
| 07 | Government 501(c)(1) |
| 13 | Not required to file (religious organization) |
| 14 | Not required to file (instrumentalities of states or political subdivisions) |
| 00 | Not required to file (all other) |

---

### EXCLUSIONS

The dataset excludes:  
• [Self-declared organizations](https://www.irs.gov/charities-non-profits/self-declared-exempt-organizations)  
• [Churches and religious entities](https://www.irs.gov/charities-non-profits/churches-religious-organizations) not required to file  
• [Split-interest trusts](https://www.irs.gov/charities-non-profits/split-interest-trust-information) and non-public reporting entities  

---

### METHODOLOGY

Data originate from the [IRS Exempt Organizations Business Master File](https://www.irs.gov/charities-non-profits/exempt-organizations-business-master-file-extract-eo-bmf) and follow [IRS schema documentation](https://www.irs.gov/pub/irs-soi/eo_info.pdf).  
Standardized for local use, this resource supports [community foundations](https://cof.org/foundation-type/community-foundations), [grant professionals](https://grantprofessionals.org/), and [fund development analysts](https://afpglobal.org/) identifying active exempt organizations in Greater New Bedford.
