-- Purpose: This script moves raw layoff data through a layered data pipeline (bronze → silver → gold),
-- performs deduplication, standardization, and null handling before producing a clean analytical dataset.

-- Raw Data layer (inspection only)
SELECT * FROM bronze.layoffs


-- Create staging layer for cleaning and transformation (silver layer preserves raw backup)
SELECT *
INTO silver.layoffs
FROM bronze.layoffs


-----------------------------------------------------------------

-------------- Remove Duplicates
-- Identify duplicates using a window function based on business-meaningful columns
WITH duplicates_cte AS (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off,
                         date, percentage_laid_off, stage,
                         country, funds_raised_millions
            ORDER BY date
        ) AS rn,
        *
    FROM silver.layoffs
)

-- Review duplicate rows (rn > 1 indicates duplicates)
SELECT * 
FROM duplicates_cte 
WHERE rn > 1

-- Remove duplicate records from the dataset
DELETE
FROM duplicates_cte 
WHERE rn > 1


-----------------------------------------------------------------

-------------- Standardize the Data

-- Normalize industry naming inconsistencies (e.g., Crypto variations)
SELECT DISTINCT industry
FROM silver.layoffs
ORDER BY industry

UPDATE silver.layoffs
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'

-- Normalize country naming inconsistencies (e.g., United States variations)
SELECT DISTINCT country
FROM silver.layoffs
ORDER BY country

UPDATE silver.layoffs
SET country = 'United States'
WHERE country LIKE 'United States%'

-- Ensure date values are consistently stored as DATE type
UPDATE silver.layoffs
SET date = CAST(date AS DATE)

ALTER TABLE silver.layoffs
ALTER COLUMN date DATE


-----------------------------------------------------------------

-------------- Handling NULL or blank values

-- Inspect missing industry values
SELECT *
FROM silver.layoffs
WHERE industry IS NULL
ORDER BY industry

-- Fill missing industry values using existing company-level information
SELECT
    l1.company,
    l1.industry,
    l2.company,
    l2.industry
FROM silver.layoffs AS l1
INNER JOIN silver.layoffs AS l2
    ON l1.company = l2.company
WHERE 
    l1.industry IS NULL 
    AND l2.industry IS NOT NULL

-- Propagate known industry values to missing entries within the same company (Bally's was the only one without a populated row)
UPDATE l1
SET industry = COALESCE(l1.industry, l2.industry)
FROM silver.layoffs AS l1
INNER JOIN silver.layoffs AS l2
    ON l1.company = l2.company
WHERE 
    l1.industry IS NULL 
    AND l2.industry IS NOT NULL

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values


-----------------------------------------------------------------

-------------- Load into final layer (gold)
-- Final cleaned dataset used for analytics and reporting
SELECT *
INTO gold.layoffs
FROM silver.layoffs