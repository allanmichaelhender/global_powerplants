## Creating table grouped by country and fuel type, also working out percentage share
WITH CTE2 as
(
With CTE as(
SELECT country as country_id , sum(energy_gwh_2017) as total_energy_2017
FROM global_powerplant.data_staging2
group by country
)
SELECT * 
FROM CTE
JOIN data_staging2
ON CTE.country_id = data_staging2.country
)
SELECT country, primary_fuel, avg(total_energy_2017) as total_energy,sum(energy_gwh_2017),sum(energy_gwh_2017)/avg(total_energy_2017) as energy_share_2017
FROM CTE2
group by country, primary_fuel;