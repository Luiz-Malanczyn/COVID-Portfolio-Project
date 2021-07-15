SELECT
	*
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
ORDER BY 3,4

--SELECT
--	*
--FROM CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT
	LOCATION,
	DATE,
	TOTAL_CASES,
	NEW_CASES,
	TOTAL_DEATHS,
	POPULATION
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
ORDER BY 1,2 

-- Looking at Total Cases vs total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT
	LOCATION,
	DATE,
	TOTAL_CASES,
	TOTAL_DEATHS,
	(TOTAL_DEATHS / TOTAL_CASES) * 100 AS DEATH_PERCENTAGE
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
--WHERE LOCATION LIKE '%bra%'
ORDER BY 1,2 

-- Looking at Total Cases cs Population
-- Shows what percentage of population got covid

SELECT
	LOCATION,
	DATE,
	POPULATION,
	TOTAL_CASES,
	(TOTAL_CASES / POPULATION) * 100 AS PERCENT_POPULATION_INFECTED
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
--WHERE LOCATION LIKE '%bra%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT
	LOCATION,
	POPULATION,
	MAX(TOTAL_CASES) AS HIGHEST_INFECTION_COUNT,
	MAX((TOTAL_CASES / POPULATION)) * 100 AS PERCENT_POPULATION_INFECTED
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
--WHERE LOCATION LIKE '%bra%'
GROUP BY 
	LOCATION, 
	POPULATION
ORDER BY PERCENT_POPULATION_INFECTED DESC

-- Showing Countries with Highest Death Count per Population

SELECT
	LOCATION,
	MAX(TOTAL_DEATHS) AS TOTAL_DEATH_COUNT
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
--WHERE LOCATION LIKE '%bra%'
GROUP BY 
	LOCATION
ORDER BY TOTAL_DEATH_COUNT DESC

-- Now let's break things down by continent
-- Showing continents with highest death count per population

SELECT
	LOCATION,
	MAX(TOTAL_DEATHS) AS TOTAL_DEATH_COUNT
FROM CovidDeaths
WHERE CONTINENT IS NULL
--WHERE LOCATION LIKE '%bra%'
GROUP BY 
	LOCATION
ORDER BY TOTAL_DEATH_COUNT DESC

-- Global Numbers

SELECT
	SUM(NEW_CASES) AS TOTAL_CASES,
	SUM(NEW_DEATHS) AS TOTAL_DEATHS,
	SUM(NEW_DEATHS) / SUM(NEW_CASES) * 100 AS DEATH_PERCENTAGE
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT 
	DEA.CONTINENT,
	DEA.LOCATION, 
	DEA.DATE, 
	DEA.POPULATION, 
	VAC.NEW_VACCINATIONS,
	SUM(VAC.NEW_VACCINATIONS) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLING_PEAPLE_VACCINATED
FROM covidDeaths DEA
JOIN CovidVaccinations VAC ON 
	DEA.LOCATION = VAC.LOCATION 
	AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
ORDER BY 2, 3

-- USE CTE

WITH POPS_VS_VAC (CONTINENT, LOCATION, DATE, POPULATION, NEW_VACCINATIONS, ROLLING_PEAPLE_VACCINATED)
AS (
	SELECT 
		DEA.CONTINENT,
		DEA.LOCATION, 
		DEA.DATE, 
		DEA.POPULATION, 
		VAC.NEW_VACCINATIONS,
		SUM(VAC.NEW_VACCINATIONS) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLING_PEAPLE_VACCINATED
	FROM covidDeaths DEA
	JOIN CovidVaccinations VAC ON 
		DEA.LOCATION = VAC.LOCATION 
		AND DEA.DATE = VAC.DATE
	WHERE DEA.CONTINENT IS NOT NULL
	--ORDER BY 2, 3
)
SELECT 
	*, 
	(ROLLING_PEAPLE_VACCINATED / POPULATION) * 100 
FROM POPS_VS_VAC

--TEMP TABLE

DROP TABLE IF EXISTS #PERCENT_POPULATION_VACCINATED 
CREATE TABLE #PERCENT_POPULATION_VACCINATED(
	CONTINENT NVARCHAR(255),
	LOCATION NVARCHAR(255),
	DATE DATETIME,
	POPULATION NUMERIC,
	NEW_VACCINATIONS NUMERIC,
	ROLLING_PEAPLE_VACCINATED NUMERIC
)

INSERT INTO #PERCENT_POPULATION_VACCINATED
SELECT 
	DEA.CONTINENT,
	DEA.LOCATION, 
	DEA.DATE, 
	DEA.POPULATION, 
	VAC.NEW_VACCINATIONS,
	SUM(VAC.NEW_VACCINATIONS) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLING_PEAPLE_VACCINATED
FROM covidDeaths DEA
JOIN CovidVaccinations VAC ON 
	DEA.LOCATION = VAC.LOCATION 
	AND DEA.DATE = VAC.DATE
--WHERE DEA.CONTINENT IS NOT NULL
--ORDER BY 2, 3

SELECT 
	*, 
	(ROLLING_PEAPLE_VACCINATED / POPULATION) * 100 
FROM #PERCENT_POPULATION_VACCINATED

-- Creating View to store data for later visualizations

CREATE VIEW PERCENT_POPULATION_VACCINATED
AS

SELECT 
	DEA.CONTINENT,
	DEA.LOCATION, 
	DEA.DATE, 
	DEA.POPULATION, 
	VAC.NEW_VACCINATIONS,
	SUM(VAC.NEW_VACCINATIONS) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLING_PEAPLE_VACCINATED
FROM covidDeaths DEA
JOIN CovidVaccinations VAC ON 
	DEA.LOCATION = VAC.LOCATION 
	AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
--ORDER BY 2, 3

SELECT
	*
FROM PERCENT_POPULATION_VACCINATED