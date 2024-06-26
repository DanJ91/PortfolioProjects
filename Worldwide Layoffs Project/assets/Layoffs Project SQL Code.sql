-- Data Cleaning
SELECT * 
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove any columns where neccessary

# Create a new table for cleaning data
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

-- Insert all the data into the new table
INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
FROM layoffs_staging;

--  Find duplicates

WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- create a new table to insert the rows

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

-- Delete the duplicate rows
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- Standarizing the data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- On inspection, there are industries that could be grouped together
SELECT distinct(industry)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

-- There are 2 united states in country column. One of them has a '.' at the end. Needs to be removed
SELECT DISTINCT(country)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States.%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Change the date column from string to date 
SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET  `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Looking for null values

-- 4 results for null or empty industry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- We have other entries showing Airbnb industry as travel so we can populate the row that has blank industry.
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL OR t1.industry = ''
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
SET t1.industry = t2.industry
WHERE t1.industry IS NULL OR t1.industry = ''
AND t2.industry IS NOT NULL;


-- Not enough information to populate NULL and empty values in total_laid of and percentage_laid_off
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Drop the row number column as we don't need it anymore
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- Look for max total_laid off and max percentage laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Amazon had the most layoffs over the period
SELECT company, SUM(total_laid_off) As company_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

-- shows the data is from the years 2020-2023
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Consumer and Retail sectors were the highest industries for layoffs
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

SELECT industry, YEAR(`date`) As `year`, country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry, `year`, country
HAVING `year` IS NOT NULL
ORDER BY `year` ASC;

-- 258,159 people lost their jobs in the United States
SELECT country, SUM(total_laid_off) AS tota_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

SELECT YEAR(`date`) As `year`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `year`
HAVING `year` IS NOT NULL
ORDER BY `year` DESC;

-- Looking at the progression of layoffs
SELECT SUBSTR(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTR(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY `month` ASC;

SELECT industry, SUBSTR(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTR(`date`, 1, 7) IS NOT NULL
GROUP BY `month`, industry
ORDER BY `month` ASC;

-- Total layoffs by year and country
SELECT YEAR(`date`) AS `year`, country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`), country
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY `year` ASC;

-- Google laid off the most employees in a year with 12000 in 2023. Meta 2nd with 11000 layoffs in 2022
SELECT company, YEAR(`date`), country, SUM(total_laid_off) As total_layoffs
FROM layoffs_staging2
GROUP BY company, YEAR(`date`), country
ORDER BY total_layoffs DESC;


-- Show the ranks of companies by year. Showing only the top 5 rankings
WITH Company_Year (company, years, total_layoffs) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) As total_layoffs
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_layoffs DESC) As ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE ranking <= 5;