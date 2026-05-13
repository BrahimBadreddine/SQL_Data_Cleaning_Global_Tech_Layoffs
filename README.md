# 🏢 Layoffs ETL Pipeline (SQL Server)

## 📌 Project Overview
This project builds an end-to-end ETL pipeline using SQL Server to clean and transform a global layoffs dataset.

The dataset contains company layoff records across multiple industries and countries, including information such as total layoffs, layoff percentages, funding raised, and company growth stage.

The pipeline follows a **Medallion Architecture (Bronze → Silver → Gold)** to progressively clean, standardize, and prepare data for analytics and reporting.

---

# 🏗️ Data Architecture

![ETL Architecture](assets/medallion_architecture.svg)

### 🥉 Bronze Layer (Raw Data)
- Raw source data ingested without modification
- Preserves original records for traceability and auditing
- Serves as the immutable source of truth

---

### 🥈 Silver Layer (Cleaned Data)
- Removes duplicate records
- Standardizes inconsistent categorical values
- Converts date fields into proper SQL `DATE` format
- Handles missing values using business rules
- Preserves analytical NULL values where appropriate

---

### 🥇 Gold Layer (Analytics-Ready Data)
- Final cleaned and trusted dataset
- Optimized for exploratory analysis and reporting
- Ready for dashboards and business intelligence tools

---

# 🛠️ Tech Stack
- SQL Server
- T-SQL
- ETL Pipeline Design
- Data Cleaning
- Medallion Architecture

---

# 🧹 Key Transformations

## 1. Duplicate Removal
Removed duplicate records using `ROW_NUMBER()` based on:

- Company
- Location
- Industry
- Total Laid Off
- Date
- Percentage Laid Off
- Stage
- Country
- Funds Raised

---

## 2. Data Standardization
Standardized inconsistent values such as:

- `Crypto Currency`, `Crypto/Web3` → `Crypto`
- `United States.` → `United States`

---

## 3. Date Formatting
Converted the `date` column into SQL Server `DATE` datatype to support:

- Filtering
- Aggregation
- Time-series analysis

---

## 4. Missing Value Handling
Filled missing `industry` values using existing company-level records through self-joins.

### Example

| Company | Industry |
|---|---|
| Bally's | NULL |
| Bally's | Gaming |

---

## 5. NULL Preservation
Retained NULL values in:

- `total_laid_off`
- `percentage_laid_off`
- `funds_raised_millions`

to preserve source accuracy and avoid misleading assumptions.

---

# 📊 Final Output
The Gold layer provides a clean and structured layoffs dataset ready for:

- Layoff trend analysis
- Industry impact analysis
- Country-level reporting
- Executive dashboards
- BI tools (Power BI / Tableau)

---

# 🚀 Outcome
This project demonstrates practical SQL skills in:

- Data cleaning and transformation
- ETL pipeline development
- Layered data architecture design
- Real-world data quality management
- Building analytics-ready datasets

---

# 📂 Project Structure

```bash
Layoffs-ETL-Pipeline/
│
├── datasets/
│   └── layoffs.csv
│
├── scripts/
│   ├── bronze_layer.sql
│   ├── silver_layer.sql
│   └── gold_layer.sql
│
├── assets/
│   └── medallion_architecture.svg
│
└── README.md
