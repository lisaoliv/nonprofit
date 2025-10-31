## PACE Donor Prospect Analysis (IRS EO BMF, Massachusetts subset)
## Goal: Identify potential funders (capacity + mission alignment) in Greater New Bedford and export a ranked contact list.
## Data: eo_ma.csv (IRS EO BMF extract).

## ---- Libraries ----
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
  library(ggplot2)
  library(tidyr)
})

## ---- 1. Read & inspect ----
setwd()
df <- read_csv("eo_ma.csv", show_col_types = FALSE)

# Keep all variables we might need (analysis + contact)
# Note: The IRS file sometimes uses uppercase headers exactly as below.
needed_cols <- c(
  "EIN","NAME","ICO","STREET","CITY","STATE","ZIP","AFFILIATION",
  "SUBSECTION","DEDUCTIBILITY","FOUNDATION","PF_FILING_REQ_CD","STATUS","RULING",
  "NTEE_CD","ACTIVITY","ASSET_AMT","INCOME_AMT","REVENUE_AMT"
)
df <- df %>% select(any_of(needed_cols))

## ---- 2. Region filter (Greater New Bedford; MA only) ----
gnb_cities <- c("Acushnet","Dartmouth","Fairhaven","Freetown","Marion",
                "Mattapoisett","New Bedford","Rochester","Wareham")
df_reg <- df %>%
  filter(str_to_upper(coalesce(STATE, "")) == "MA") %>%
  filter(str_to_title(coalesce(CITY, "")) %in% gnb_cities)

## ---- 3. Quality filters: active + deductible (robust) ----
norm_code <- function(x) {
  x <- ifelse(is.na(x), NA, as.character(x))
  x <- stringr::str_trim(x)
  x <- toupper(x)
  x
}

df_reg <- df_reg %>%
  mutate(
    STATUS_N     = norm_code(STATUS),
    DEDUCT_N     = norm_code(DEDUCTIBILITY),
    PF_REQ_N     = norm_code(PF_FILING_REQ_CD),
    FOUND_N      = norm_code(FOUNDATION)
  )

# Treat “active” broadly: 1 / 01 / A / ACTIVE all okay; if STATUS missing, keep.
active_vals <- c("1","01","A","ACTIVE")
df_reg <- df_reg %>%
  filter(is.na(STATUS_N) | STATUS_N %in% active_vals)

# Deductibility == 1 is ideal; allow NA (some extracts omit).
df_reg <- df_reg %>%
  filter(is.na(DEDUCT_N) | DEDUCT_N %in% c("1","01"))

cat("Rows after region+quality filters:", nrow(df_reg), "\n")

## ---- 4. Likely grantmakers (more tolerant) ----
# PF filing indicators seen in the wild: 1, 01, PF, Y, TRUE
is_pf_by_filing <- df_reg$PF_REQ_N %in% c("1","01","PF","Y","TRUE")
# Foundation codes often “02” (private operating) and “03” (private non-operating)
is_pf_by_code   <- df_reg$FOUND_N %in% c("2","3","02","03","PVT","PRIVATE")

df_reg <- df_reg %>%
  mutate(
    is_pf_by_filing = is_pf_by_filing,
    is_pf_by_code   = is_pf_by_code
  )

cat("Grantmaker flags (filing/code) counts:",
    sum(df_reg$is_pf_by_filing, na.rm=TRUE), "/",
    sum(df_reg$is_pf_by_code,   na.rm=TRUE), "\n")

## ---- 5. Mission alignment (unchanged) ----
pace_ntee_prefix <- c("P","B","E","L","S","T","C","K")
df_reg <- df_reg %>%
  mutate(
    NTEE_PREFIX = str_sub(coalesce(NTEE_CD, ""), 1, 1),
    mission_aligned = NTEE_PREFIX %in% pace_ntee_prefix
  )

## ---- 6. Capacity score (make sure numerics are numerics) ----
safe_num <- function(x) suppressWarnings(as.numeric(gsub("[^0-9.-]","", x)))
df_reg <- df_reg %>%
  mutate(
    ASSET_AMT   = safe_num(ASSET_AMT),
    INCOME_AMT  = safe_num(INCOME_AMT),
    REVENUE_AMT = safe_num(REVENUE_AMT),
    cap_assets  = log10(coalesce(ASSET_AMT, 0)  + 1),
    cap_income  = log10(coalesce(INCOME_AMT, 0) + 1),
    capacity_score = rowMeans(cbind(cap_assets, cap_income), na.rm = TRUE)
  )

## ---- 7. Choose the funder pool (with fallback) ----
df_funders <- df_reg %>% filter(is_pf_by_filing | is_pf_by_code)
cat("Rows with PF heuristic:", nrow(df_funders), "\n")

if (nrow(df_funders) == 0) {
  # Fallback: mission-aligned + basic capacity threshold
  df_funders <- df_reg %>%
    filter(mission_aligned) %>%
    filter(coalesce(ASSET_AMT, 0) > 1000 | coalesce(INCOME_AMT, 0) > 1000)
  cat("Fallback rows (mission-aligned + capacity):", nrow(df_funders), "\n")
}

## ---- 8. Order by compatibility then capacity ----
ordered <- df_funders %>%
  arrange(desc(mission_aligned), desc(capacity_score)) %>%
  select(EIN, NAME, ICO, STREET, CITY, STATE, ZIP,
         SUBSECTION, DEDUCTIBILITY, FOUNDATION, PF_FILING_REQ_CD, STATUS, RULING,
         NTEE_CD, ACTIVITY,
         ASSET_AMT, INCOME_AMT, REVENUE_AMT,
         mission_aligned, capacity_score, AFFILIATION)

cat("Final ordered rows:", nrow(ordered), "\n")

# Quick peek tables to validate codes
cat("\nUnique FOUNDATION codes:\n"); print(sort(table(df_reg$FOUND_N), decreasing=TRUE)[1:10])
cat("\nUnique PF_FILING_REQ_CD codes:\n"); print(sort(table(df_reg$PF_REQ_N), decreasing=TRUE)[1:10])

## ---- 9. Summaries (Professor-style language) ----
# Numeric summaries
numeric_vars <- c("ASSET_AMT","INCOME_AMT","REVENUE_AMT")
for (v in numeric_vars) {
  cat("\n\n----- Descriptive statistics for", v, "-----\n")
  print(summary(ordered[[v]]))         # “provides most of the existent descriptive statistics”
  cat("sd:", sd(ordered[[v]], na.rm = TRUE), "\n")  # “returns the standard deviation”
  # Example interpretation line for template:
  # Mean = X -> Interpretation: On average, organizations report X in {v}.
}

ordered <- ordered %>%
  mutate(NTEE_PREFIX = str_sub(coalesce(NTEE_CD, ""), 1, 1))

# Categorical frequency examples
cat("\n\n----- Frequency analysis: FOUNDATION (categorical) -----\n")
print(sort(table(ordered$FOUNDATION), decreasing = TRUE))

cat("\n\n----- Frequency analysis: NTEE first-letter prefix (categorical) -----\n")
print(sort(table(ordered$NTEE_PREFIX), decreasing = TRUE))

## ---- 10. Visuals (numeric = histogram; categorical = bar) ----
# Numeric histograms (log scale used upstream to stabilize skew; plot the raw values for intuition)
plot_hist <- function(vec, title) {
  ggplot(data.frame(x = vec), aes(x)) +
    geom_histogram(bins = 30) +
    labs(title = title, x = title, y = "Frequency")
}
print(plot_hist(ordered$ASSET_AMT,  "Assets (ASSET_AMT)"))
print(plot_hist(ordered$INCOME_AMT, "Income (INCOME_AMT)"))
print(plot_hist(ordered$REVENUE_AMT,"Revenue (REVENUE_AMT)"))

# Categorical bar: top NTEE prefixes
ggplot(ordered %>% filter(NTEE_PREFIX != "") %>% count(NTEE_PREFIX), aes(x = reorder(NTEE_PREFIX, -n), y = n)) +
  geom_bar(stat = "identity") +
  labs(title = "NTEE Prefix Frequency (Greater New Bedford funders)", x = "NTEE Prefix", y = "Count")

## ---- 11. Export: ALL potential funders (ordered) ----
write_csv(ordered, "potential_donors.csv")
cat("\nExported: potential_donors.csv (all candidates, most compatible at top).\n")

## ---- Notes for reviewers ----
# - DEDUCTIBILITY == 1 ensures contributions to these orgs are tax-deductible; it does NOT by itself make them grantmakers.
# - Grantmaker flags rely on PF_FILING_REQ_CD and/or FOUNDATION codes (heuristics vary across BMF vintages).
# - Consider enriching with IRS 990-PF “grants made” data to see actual giving history; then you can build predictive or network models.
