--Select *
--from PortfolioProject_Alex.dbo.CovidDeaths
--order by 3,4

--Select *
--from PortfolioProject_Alex.dbo.CovidVaccinations
--order by 3,4



-- SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_Alex.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- LOOKING AT TOTAL CASES vs TOTAL DEATHS
	-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject_Alex.dbo.CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2



-- Looking at Total Cases vs Population
	-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject_Alex.dbo.CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2



-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject_Alex.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC



-- Showing countries with the highest death count per population

SELECT location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject_Alex.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Let's break things down by continent

SELECT continent, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject_Alex.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Esse seria o select correto, mas para ficar igual ao video vou manter o select acima.

--SELECT location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
--FROM PortfolioProject_Alex.dbo.CovidDeaths
--WHERE continent is null
--GROUP BY location
--ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject_Alex.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
	--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject_Alex.Dbo.CovidDeaths  dea
JOIN PortfolioProject_Alex.Dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Use CTE

WITH PopVsVac (Contient, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject_Alex.Dbo.CovidDeaths  dea
JOIN PortfolioProject_Alex.Dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopVsVac



-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject_Alex.Dbo.CovidDeaths  dea
JOIN PortfolioProject_Alex.Dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject_Alex.Dbo.CovidDeaths  dea
JOIN PortfolioProject_Alex.Dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT * 
FROM PercentPopulationVaccinated