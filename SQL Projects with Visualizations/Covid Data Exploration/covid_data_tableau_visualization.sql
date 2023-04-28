USE covid;

-- Calculating Death Percentage

-- 1
SELECT
	SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths,
    (SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases))*100 AS death_percentage
FROM covid_deaths
WHERE continent != ''
ORDER BY location;

-- 2

SELECT
	location,
    SUM(CAST(new_deaths AS UNSIGNED)) AS total_death_count
FROM covid_deaths
WHERE continent = '' AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY total_death_count DESC;

-- 3

SELECT
	location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
WHERE continent != ''
GROUP BY location
ORDER BY percent_population_infected DESC;

-- 4

SELECT
	location,
    population,
    date,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
WHERE continent != ''
GROUP BY location, population, date
ORDER BY percent_population_infected DESC;


-- ORIGINALLY

SELECT
	d.continent,
    d.location,
    d.date,
    d.population,
    MAX(CAST(v.total_vaccinations AS UNSIGNED)) AS rolling_people_vaccinated
FROM covid_deaths d
JOIN covid_vaccinations v ON d.location = v.location
WHERE d.continent != ''
GROUP BY d.location
ORDER BY d.location;
    
WITH PopvsVac (continent. location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
d.continent,
d.location,
d.date,
d.population,
SUM(CAST(v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM d.covid_deaths d
JOIN v.covid_vaccinations d ON d.location = v.location AND d.date = v.date
WHERE continent != ''
ORDER BY d.location
)
SELECT 
	*,
    (rolling_people_vaccinated/population)*100 AS percent_people_vaccinated
FROM PopvsVac;







