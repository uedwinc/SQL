USE covid;

SELECT 
    *
FROM
    covid_deaths;

SELECT 
    *
FROM
    covid_vaccinations;

-- Our Dataset contains continent and location(country) columns. 
-- Inorder to do away with situations where location takes the name of entire continent and continent is null i.e '', 
-- we'll use a where clause to remove rows where continent is null in certain cases.


-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- This shows the likelihood of dying if you contract covid in your country
SELECT 
    location, 
    date,
    total_cases, 
    total_deaths,
    ROUND((total_deaths/total_cases)*100, 4) AS death_percentage
FROM
    covid_deaths;

-- LOOKING AT TOTAL CASES VS POPULATION
-- Shows what percentage of the population got covid
SELECT 
    location, 
    date,
    total_cases, 
    population,
    ROUND((total_cases/population)*100, 4) AS percentage_infected
FROM
    covid_deaths;

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO IT'S POPULATION
SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases / population) * 100) AS percentage_infected
FROM covid_deaths
GROUP BY location
ORDER BY percentage_infected DESC;

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT
SELECT 
    location,
    MAX(CAST(total_deaths AS UNSIGNED)) AS highest_death_count
FROM covid_deaths
WHERE continent != ''
GROUP BY location
ORDER BY highest_death_count DESC;



-- LET'S BREAK THINGS DOWN BY CONTINENT

-- LOOKING AT TOTAL DEATHS PER CONTINENT
SELECT continent, SUM(max_deaths) AS total_deaths
FROM (
    SELECT continent, location, MAX(CAST(total_deaths AS UNSIGNED)) AS max_deaths
    FROM covid_deaths
    GROUP BY continent, location
) AS max_deaths_per_country
WHERE continent != ''
GROUP BY continent;

-- LET'S CREATE A VIEW TO HOLD DATA FOR TOTAL DEATHS PER CONTINENT

CREATE OR REPLACE VIEW v_death_percentage AS
SELECT continent, SUM(max_deaths) AS total_deaths
FROM (
    SELECT continent, location, MAX(CAST(total_deaths AS UNSIGNED)) AS max_deaths
    FROM covid_deaths
    GROUP BY continent, location
) AS max_deaths_per_country
WHERE continent != ''
GROUP BY continent;



-- GLOBAL DEATH PERCENTAGE

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths,
    (SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases)) * 100 AS death_percentage
FROM
    covid_deaths
WHERE
    continent != '';


-- Joining the covid_deaths and the covid_vaccinations table

-- AND LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations
FROM
    covid_deaths cd
        JOIN
    covid_vaccinations cv ON cd.location = cv.location
        AND cd.date = cv.date
WHERE
    cd.continent != ''
ORDER BY
	cd.location;

-- NEXT, WE GET A ROLLING SUM OF THE NEW VACCINATIONS PARTITIONED BY LOCATION

SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    CAST(cv.new_vaccinations AS UNSIGNED) AS new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM
    covid_deaths cd
        JOIN
    covid_vaccinations cv ON cv.location = cd.location
        AND cv.date = cd.date
WHERE
    cd.continent != ''
ORDER BY
	cd.location, cd.date;
    

-- USING CTE TO OBTAIN THE MAXIMUM AND PERCENTAGE OF ROLLING PEOPLE VACCINATED

WITH pop_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
(
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    CAST(cv.new_vaccinations AS UNSIGNED) AS new_vaccinations,
    SUM(CAST(cv.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM
    covid_deaths cd
        JOIN
    covid_vaccinations cv ON cv.location = cd.location
        AND cv.date = cd.date
WHERE
    cd.continent != ''
ORDER BY
	cd.location, cd.date
)
SELECT
	*, ROUND((rolling_people_vaccinated/population)*100, 4) AS percent_of_rolling_people_vaccinated
FROM pop_vac;
    
    
-- LET'S CREATE A TEMPORARY TABLE TO HOLD THE DATA FOR PERCENT OF POPULATION VACCINATED

CREATE TEMPORARY TABLE percent_population_vaccinated
WITH pop_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
(
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM
    covid_deaths cd
        JOIN
    covid_vaccinations cv ON cv.location = cd.location
        AND cv.date = cd.date
WHERE
    cd.continent != ''
ORDER BY
	cd.location, cd.date
)
SELECT
	*, ROUND((rolling_people_vaccinated/population)*100, 4) AS percent_of_rolling_people_vaccinated
FROM pop_vac;

SELECT 
    *
FROM
    percent_population_vaccinated;


