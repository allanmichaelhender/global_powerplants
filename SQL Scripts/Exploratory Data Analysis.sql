## Exploratory Data Analysis

## Looking at top power producing countries
SELECT country,  sum(capacity_mw) total_capacity_mw, sum(energy_gwh_2013) 2013_generation_gwh
FROM global_powerplant.data_staging2
GROUP BY country
ORDER BY total_capacity_mw DESC
LIMIT 50;

## Looking at change in energy generation
SELECT country, sum(energy_gwh_2013) as 2013_total, sum(energy_gwh_2014) as 2014_total, sum(energy_gwh_2015) as 2015_total, sum(energy_gwh_2016) as 2016_total, sum(energy_gwh_2017) as 2017_total,
(sum(energy_gwh_2017)-sum(energy_gwh_2013))
FROM data_staging2
WHERE energy_gwh_2017 is not NULL
GROUP BY country
ORDER BY 2017_total DESC;
## The sharp uptick in 2017 indicates the amount of powerstations being reported has increased significantly, we need to find another way to look into this question#

## Instead lets limit to power stations with full data
SELECT country, `name`, energy_gwh_2013, energy_gwh_2014,energy_gwh_2015,energy_gwh_2016,energy_gwh_2017
FROM data_staging2
WHERE energy_gwh_2013 is not NULL
AND energy_gwh_2013 != 0
AND energy_gwh_2014 is not NULL
AND energy_gwh_2014 != 0
AND energy_gwh_2015 is not NULL
AND energy_gwh_2015 != 0
AND energy_gwh_2016 is not NULL
AND energy_gwh_2016 != 0
AND energy_gwh_2017 is not NULL
AND energy_gwh_2017 != 0;

## Let us use a CTE to group this data
WITH CTE_table as
(
SELECT country, `name`, energy_gwh_2013, energy_gwh_2014,energy_gwh_2015,energy_gwh_2016,energy_gwh_2017
FROM data_staging2
WHERE energy_gwh_2013 is not NULL
AND energy_gwh_2013 != 0
AND energy_gwh_2014 is not NULL
AND energy_gwh_2014 != 0
AND energy_gwh_2015 is not NULL
AND energy_gwh_2015 != 0
AND energy_gwh_2016 is not NULL
AND energy_gwh_2016 != 0
AND energy_gwh_2017 is not NULL
AND energy_gwh_2017 != 0
)
SELECT country, sum(energy_gwh_2013) as 2013_total, sum(energy_gwh_2014) as 2014_total, sum(energy_gwh_2015) as 2015_total, sum(energy_gwh_2016) as 2016_total, sum(energy_gwh_2017) as 2017_total,
(sum(energy_gwh_2017)-sum(energy_gwh_2013)) as change_gwh, 100*(sum(energy_gwh_2017)-sum(energy_gwh_2013))/sum(energy_gwh_2013) as change_percentage
FROM CTE_table
GROUP BY country
ORDER BY 2017_total DESC;

## Looking into fuel types
SELECT primary_fuel, sum(capacity_mw) total_capacity_mw, sum(energy_gwh_2017) energy_generation_2017
FROM data_staging2
GROUP BY primary_fuel
ORDER BY sum(capacity_mw) DESC;