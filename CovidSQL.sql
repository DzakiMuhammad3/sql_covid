-- Test the tables
SELECT *
FROM portofoliodb.dbo.CovidVaccinations;

SELECT* 
FROM portofoliodb.dbo.CovidDeaths 
ORDER BY 3;

-- Total Deaths
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portofoliodb..CovidDeaths;

-- Total Deaths in Indonesia
SELECT location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 AS death_percentages
FROM portofoliodb..CovidDeaths
WHERE location like '%indo%';

SELECT location, date, total_cases, population,(total_cases/population)*100 AS death_percentages
FROM portofoliodb..CovidDeaths
WHERE location like '%indo%';


-- Looking at country with the most total cases 
SELECT location, population, MAX(total_cases) AS highest_infection_count, (max(total_cases)/population)*100 AS percent_max
FROM portofoliodb..CovidDeaths
GROUP BY location,population
ORDER BY 4 desc;

-- Shows the country with highes death count
SELECT location, total_deaths, MAX(total_deaths) AS highest_death_count, (max(total_deaths)/population)*100 AS percent_max
FROM portofoliodb..CovidDeaths
GROUP BY location,population
ORDER BY 4 desc;

SELECT location, max(cast(total_deaths AS int)) AS most_death, max(cast(total_deaths AS int))/avg(population)*100 AS percentage_most_death
FROM portofoliodb..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 desc;

SELECT continent, max(cast(total_deaths AS int)) AS most_death, max(cast(total_deaths AS int))/avg(population)*100 AS percentage_most_death
FROM portofoliodb..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 desc;

-- Continent is null but Location is not, I think because it's AS whole continent
SELECT location, max(cast(total_deaths AS int)) AS most_death, max(cast(total_deaths AS int))/avg(population)*100 AS percentage_most_death
FROM portofoliodb..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY 2 desc;


-- GLOBAL NUMBERS
SELECT date, SUM(total_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_new_cases, SUM(cast(new_deaths AS int))/SUM(total_cases)*100 AS percentage
FROM portofoliodb..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

SELECT SUM(total_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_new_cases, SUM(cast(new_deaths AS int))/SUM(total_cases)*100 AS percentage
FROM portofoliodb..CovidDeaths
WHERE continent is not null AND date > '2020-01-23'
ORDER BY 1,2;



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM portofoliodb..CovidDeaths dea
JOIN portofoliodb..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- USE CTE
with PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM portofoliodb..CovidDeaths dea
JOIN portofoliodb..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Creating Temporary Table
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)


--Inserting to temporary table
DROP TABLE #PercentPopulationVaccinated

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations AS int)
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM portofoliodb..CovidDeaths dea
JOIN portofoliodb..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualization
Create view PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations AS int) AS new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM portofoliodb..CovidDeaths dea
JOIN portofoliodb..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null