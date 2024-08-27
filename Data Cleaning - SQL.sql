SELECT 
    *
FROM
    LAYOFFS;

CREATE TABLE layoffs_staging LIKE layoffs;

SELECT 
    *
FROM
    layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `DATE`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY 
		company
        ,location
        ,industry
        ,total_laid_off
        ,percentage_laid_off
        ,`DATE`
        ,stage
        ,country
        ,funds_raised_millions
        ) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;



INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY 
		company
        ,location
        ,industry
        ,total_laid_off
        ,percentage_laid_off
        ,`DATE`
        ,stage
        ,country
        ,funds_raised_millions
        ) AS row_num
FROM layoffs_staging;

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    row_num > 1;

DELETE FROM layoffs_staging2 
WHERE
    row_num > 1;

SELECT 
    *
FROM
    layoffs_staging2;

-- STANDARDIZING
UPDATE layoffs_staging2 
SET 
    company = TRIM(company);

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry LIKE '%Crypto%';

UPDATE layoffs_staging2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE '%Crypto%';

UPDATE layoffs_staging2 
SET 
    location = 'Florianópolis'
WHERE
    location LIKE '%FlorianÃ³polis%'

SELECT DISTINCT
country,
TRIM(TRAILING '.' FROM COUNTRY)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM COUNTRY)
WHERE country LIKE 'United States%';

SELECT DISTINCT country
FROM layoffs_staging2
order by country;

SELECT 
`date`, 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL OR industry = ''

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT 
    *
FROM
    layoffs_staging2

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
