Select top 1000 *
From CovidDeaths
WHERE continent IS not NULL
Order by 3, 4;

--Select *
--From CovidVaccinations
--Order by 3, 4;

-- Select Data that we are going to be using
--SELECT TOP 20 location, date, total_cases, new_cases, total_deaths, population
--FROM CovidDeaths
--ORDER BY 1, 2;


-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you ocntract covid in your country
SELECT TOP 1000 location, date, total_cases, total_deaths, (
	Total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Looking at the total cases vs population
-- Shows what percentage of population got covid
SELECT TOP 1000 location, date, total_cases, population, 
	(Total_cases/population)*100 AS cases_percentage
FROM CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Looking at countries with highest infection rate compared to population
SELECT location,
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((Total_cases/population))*100 AS percent_population_infected
FROM CovidDeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- SHowing countries with highest death count per location
SELECT location, MAX(CAST(total_deaths as INT)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Break by continent

-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as INT)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global numbers
SELECT date,
	SUM(new_cases) as total_cases, 
	SUM(CAST(new_deaths as int)) as total_deaths,
	SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as death_percentage 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

SELECT
	SUM(new_cases) as total_cases, 
	SUM(CAST(new_deaths as int)) as total_deaths,
	SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as death_percentage 
FROM CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2;

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(real,vac.new_vaccinations)) OVER 
	(
	PARTITION BY dea.location
	ORDER BY dea.location, dea.date
	) AS rolling_people_vaccinated
	-- (rolling_people_vaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
	AS
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(real,vac.new_vaccinations)) OVER 
	(
	PARTITION BY dea.location
	ORDER BY dea.location, dea.date
	) AS rolling_people_vaccinated
	-- (rolling_people_vaccinated/population)*100
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	-- ORDER BY 2,3
	)
SELECT *, (rolling_people_vaccinated/population)*100
FROM pop_vs_vac;


-- TEMP TABLE
Drop table if exists #Percent_population_vaccinated
Create table #Percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric, 
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
Insert into #percent_population_vaccinated 
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(real,vac.new_vaccinations)) OVER 
	(
	PARTITION BY dea.location
	ORDER BY dea.location, dea.date
	) AS rolling_people_vaccinated
	-- (rolling_people_vaccinated/population)*100
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	-- ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #percent_population_vaccinated;



-- Creating view to store data for later visualizations

Create View percent_population_vaccinated as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(real,vac.new_vaccinations)) OVER 
	(
	PARTITION BY dea.location
	ORDER BY dea.location, dea.date
	) AS rolling_people_vaccinated
	-- (rolling_people_vaccinated/population)*100
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	-- ORDER BY 2,3

SELECT *
FROM percent_