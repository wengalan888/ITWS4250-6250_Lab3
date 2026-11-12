-- lab 3


WITH RECURSIVE CityToCountry(city_id, parent_id) AS (
  -- find all city and states
  SELECT region_id, parent_id
  FROM Region
  WHERE admin_level = 2

  -- combine rows with new ones
  UNION ALL

  -- find country while keeping city (makes city, country)
  SELECT c.city_id, r.parent_id
  FROM CityToCountry c
  JOIN Region r ON c.parent_id = r.region_id

  -- stop when no more parent (countries no parent)
  WHERE r.parent_id IS NOT NULL
)

-- country, total_cases
SELECT country.name AS country, SUM(cr.case_count) AS total_cases
FROM CityToCountry c

-- where city is in country
JOIN Region country ON c.parent_id = country.region_id

-- where case report of city is the same city of c
-- get case report for city
JOIN CaseReport cr ON c.city_id = cr.city_id

-- only keep countries
WHERE country.admin_level = 0

-- add cases
GROUP BY country.region_id, country.name
ORDER BY total_cases DESC;

