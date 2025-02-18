--Checks whether data was imported via the "SQL Server 2022 Import and Export Data” wizard.
SELECT *
FROM COVIDPortfolioProject.dbo.CovidDeaths
ORDER BY 3,4; --Orders by location and date.

SELECT *
FROM COVIDPortfolioProject.dbo.CovidVaccinations
ORDER BY 3,4; --Orders by location and date.

--After exploring the data we see some continents located in the 'location' column
--Those columns have a null in the continent field
--Those that are not null are countries
SELECT *
FROM COVIDPortfolioProject.dbo.CovidVaccinations
WHERE continent is not null
ORDER BY 3,4; --Orders by location and date.

--Selects data that I am going to be using.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVIDPortfolioProject.dbo.CovidDeaths
ORDER BY 1,2 --Orders by location, date

--Shows total cases vs total deaths
-- Shows likelihood of dying if you contract covid your country.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage -- Alias for death percentage calculated field.
FROM COVIDPortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2 --Orders by location, date

--Shows total cases vs population
--Shows what percentage of the population contracted covid.
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS death_percentage -- Alias for death percentage calculated field.
FROM COVIDPortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2 --Orders by location, date

--Looks at countries with the highest infection rate compared to the population.
SELECT location, population, max(total_cases) as highest_infection_count, MAX((total_cases/population)) * 100 AS percent_population_infected -- Alias for death percentage calculated field.
FROM COVIDPortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY percent_population_infected desc

--Shows countries with highest death count per population
SELECT location, max(cast(total_deaths as int)) as total_death_count
FROM COVIDPortfolioProject.dbo.CovidDeaths
where continent is not null
GROUP BY location
ORDER BY total_death_count desc

--Shows continents with highest death count per population
SELECT continent, max(cast(total_deaths as int)) as total_death_count
FROM COVIDPortfolioProject.dbo.CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY total_death_count desc

--Shows total_cases, total_deaths, death_percentage across the entire globe.
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths,
	(SUM(CAST(new_deaths as INT))/SUM(new_cases)) * 100 AS death_percentage
FROM COVIDPortfolioProject.dbo.CovidDeaths
where continent is not null
ORDER BY 1,2 --orders by total_cases and total_deaths


--Shows total population vs total vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) --Calculates running sum of vaccinations
	AS running_sum_people_vaccinated
FROM COVIDPortfolioProject.dbo.CovidDeaths dea
join COVIDPortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3; --orders by continent and location

--Uses CTE to calculate the running perentage of people vaccinated per country
WITH PopvsVac(continent, location, date, population, new_vaccinations, running_sum_people_vaccinated)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) --Calculates running sum of vaccinations
	AS running_sum_people_vaccinated
	FROM COVIDPortfolioProject.dbo.CovidDeaths dea
	join COVIDPortfolioProject.dbo.CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
)
SELECT *, (running_sum_people_vaccinated/population) * 100
FROM PopvsVac
ORDER BY 2,3

--Uses temp table to calculate the running perentage of people vaccinated per country
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent NVARCHAR(255),
	location NVARCHAR(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	running_sum_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) --Calculates running sum of vaccinations
	AS running_sum_people_vaccinated
	FROM COVIDPortfolioProject.dbo.CovidDeaths dea
	join COVIDPortfolioProject.dbo.CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null

SELECT *, (running_sum_people_vaccinated/population) * 100
FROM #PercentPopulationVaccinated
ORDER BY 2,3

--Creates view to store data for later visualizations
GO
DROP VIEW IF EXISTS PercentPopulationVaccinated

GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date) --Calculates running sum of vaccinations
	AS running_sum_people_vaccinated
	FROM COVIDPortfolioProject.dbo.CovidDeaths dea
	join COVIDPortfolioProject.dbo.CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null

GO
SELECT *, (running_sum_people_vaccinated/population) * 100
FROM PercentPopulationVaccinated
ORDER BY 2,3