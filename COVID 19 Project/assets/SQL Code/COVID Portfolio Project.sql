SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `sql-start-04122023.covid_data.covid_deaths`
WHERE continent IS NOT NULL 
ORDER BY 1, 2 LIMIT 1000;

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases)*100,2) AS death_percentage
FROM `sql-start-04122023.covid_data.covid_deaths` 
WHERE location = 'United States' AND continent IS NOT NULL 
ORDER BY 1, 2 LIMIT 1000;

-- Looking at the total cases vs population
-- Shows what % of the population contracted Covid

SELECT location, date, population, total_cases, ROUND((total_cases / population)*100,2) AS percent_of_population_infected
FROM `sql-start-04122023.covid_data.covid_deaths` 
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY 1, 2 LIMIT 1000;

-- Looking at countries with the highest infection rate % by population

SELECT location, population, MAX(total_cases) AS highest_infection_count, ROUND(MAX((total_cases / population)*100),2) AS percent_of_population_infected
FROM `sql-start-04122023.covid_data.covid_deaths` 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_of_population_infected DESC;

-- Showing the continents with the highest death count per population
-- The below query was actually wrong so had to find the correct data using a different query
SELECT continent, MAX(total_deaths) AS total_death_count
FROM `sql-start-04122023.covid_data.covid_deaths` 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;
-- This query yielded the correct result
SELECT location, MAX(total_deaths) AS total_death_count
FROM `sql-start-04122023.covid_data.covid_deaths` 
WHERE continent IS NULL AND location NOT IN ('World', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY total_death_count DESC;

-- Showing the countries with the highest death count per population

SELECT location, MAX(total_deaths) AS total_death_count
FROM `sql-start-04122023.covid_data.covid_deaths` 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Showing the countries with the highest death count per population

SELECT location, MAX(total_deaths) AS total_death_count
FROM `sql-start-04122023.covid_data.covid_deaths` 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Global Numbers

SELECT SUM(new_cases) AS total_cases_worldwide, SUM(new_deaths) AS total_deaths_worldwide, ROUND(SUM(new_deaths) / sum(new_cases) * 100,2) AS death_percentage_worldwide
FROM `sql-start-04122023.covid_data.covid_deaths`
WHERE continent IS NOT NULL;

-- Vaccinations table

SELECT * FROM `sql-start-04122023.covid_data.covid_vaccinations`
LIMIT 10;

-- Join the deaths and vaccinations tables together

SELECT * 
FROM `sql-start-04122023.covid_data.covid_deaths` d
JOIN `sql-start-04122023.covid_data.covid_vaccinations` v
ON d.location = v.location AND d.date = v.date
LIMIT 10;

-- Looking at total population vs vaccinations

-- create a view to store this query so we can use rolling average
CREATE VIEW covid_data.popvsvac AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.date) AS rolling_vaccinations
FROM `sql-start-04122023.covid_data.covid_deaths` d
JOIN `sql-start-04122023.covid_data.covid_vaccinations` v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

-- Find the % of popluation vaccinated
SELECT date, continent, location, (rolling_vaccinations/population) * 100 AS percent_of_pop_vaccinated 
FROM `sql-start-04122023.covid_data.popvsvac`;