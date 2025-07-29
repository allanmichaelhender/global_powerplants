## Cleaning the Data

## Create Staging Table
CREATE TABLE data_staging 
LIKE data_raw;

INSERT data_staging
SELECT *
FROM data_raw;

## Remove Duplicates
	## Checking for duplicates with CTE Function

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY country_long, `name`, primary_fuel, capacity_mw) as row_num
FROM data_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

## We have 5 duplicates to remove, we will create a second staging table with
## a column for the row_num, then remove all the values more than 1
CREATE TABLE `data_staging2` (
  `_record_number` int NOT NULL AUTO_INCREMENT,
  `id` int DEFAULT NULL,
  `country_long` varchar(32) DEFAULT NULL,
  `name` varchar(87) DEFAULT NULL,
  `capacity_mw` decimal(22,16) DEFAULT NULL,
  `primary_fuel` varchar(14) DEFAULT NULL,
  `commissioning_year` varchar(18) DEFAULT NULL,
  `estimated_generation_gwh_2013` varchar(8) DEFAULT NULL,
  `estimated_generation_gwh_2014` varchar(8) DEFAULT NULL,
  `estimated_generation_gwh_2015` varchar(8) DEFAULT NULL,
  `estimated_generation_gwh_2016` varchar(8) DEFAULT NULL,
  `estimated_generation_gwh_2017` varchar(8) DEFAULT NULL,
  `row_num` INT,
  PRIMARY KEY (`_record_number`)
) ENGINE=InnoDB AUTO_INCREMENT=34937 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Table imported using\nCSV Lint plug-in: v0.4.6.8\nFile: test.csv\nDate: 29-Jul-2025 17:07';

INSERT INTO data_staging2
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY country_long, `name`, primary_fuel, capacity_mw) as row_num
FROM data_staging;

## Deleting the duplicate rows
DELETE
FROM data_staging2
WHERE row_num > 1;

## Standardising the data
## We want to remove the date values after the decimal eg 1986.05 -> 1986
UPDATE data_staging2
SET commissioning_year = substring(commissioning_year,1,4) ;

## Renaming columns to index and setting commisioning year to integer
ALTER TABLE `global_powerplant`.`data_staging2` 
CHANGE COLUMN `_record_number` `index` INT NOT NULL AUTO_INCREMENT,
CHANGE COLUMN `country_long` `country` VARCHAR(32) NULL DEFAULT NULL ,
CHANGE COLUMN `estimated_generation_gwh_2013` `energy_gwh_2013` VARCHAR(8) NULL DEFAULT NULL ,
CHANGE COLUMN `estimated_generation_gwh_2014` `energy_gwh_2014` VARCHAR(8) NULL DEFAULT NULL ,
CHANGE COLUMN `estimated_generation_gwh_2015` `energy_gwh_2015` VARCHAR(8) NULL DEFAULT NULL ,
CHANGE COLUMN `estimated_generation_gwh_2016` `energy_gwh_2016` VARCHAR(8) NULL DEFAULT NULL ,
CHANGE COLUMN `estimated_generation_gwh_2017` `energy_gwh_2017` VARCHAR(8) NULL DEFAULT NULL ;



ALTER TABLE `global_powerplant`.`data_staging2` 
CHANGE COLUMN `commissioning_year` `commissioning_year` INT NULL DEFAULT NULL ;

##Remove unwanted colkumns
SELECT *
FROM data_staging2;

ALTER TABLE data_staging2
DROP COLUMN id;
