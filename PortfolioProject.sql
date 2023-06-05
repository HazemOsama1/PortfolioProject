SELECT *
FROM Portfolio_project.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM Portfolio_project.dbo.CovidVaccinations
ORDER BY 3,4

--Select Data that I'm going to use

SELECT Location, date, total_cases, new_cases, total_deaths, new_deaths
FROM Portfolio_project..CovidDeaths
ORDER BY 1,2

--Total_deaths and Total_cases in Egypt

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercrntage
FROM Portfolio_project..CovidDeaths
WHERE location = 'Egypt'
AND continent is not null
ORDER BY 1,2

--Total cases and total population all over the world

SELECT Location, date, total_cases, Population, (total_Cases/Population)*100 AS PercentageInfectedPopulation
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Countries with the highest Infection rate compared to population

SELECT Location,Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
GROUP BY Location, population 
ORDER BY 3 desc

--Countries with Highest Death Count per Population

SELECT Location, Population, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount, MAX((CAST(total_deaths AS INT)/Population)*100) AS HighestDeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
GROUP BY Location, population 
ORDER BY 3 desc

--Contintents with the highest death count per population

SELECT continent,MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
GROUP BY continent
Order by 2 desc

--Global Numbers Per Day

SELECT Date, SUM(new_cases) AS TotalCases, SUM(CAST(New_deaths AS INT)) TotalDeaths,
(SUM(cast(new_deaths as int))/SUM(New_Cases))*100 as DeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT vac.location, vac.continent, vac.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY vac.location ORDER BY vac.location, vac.date) AS TotalVacPerDay
FROM Portfolio_project..CovidVaccinations vac
Join Portfolio_project..CovidDeaths Dea
	ON vac.location = Dea.location
	AND vac.date = Dea.date
where dea.continent is not null
ORDER BY 1,3

--Using CTE to get the Percentage

WITH POP (location, continent, date, population, new_vaccinations, TotalVacPerDay)
AS
(
SELECT vac.location, vac.continent, vac.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY vac.location ORDER BY vac.location, vac.date) AS TotalVacPerDay
FROM Portfolio_project..CovidVaccinations vac
Join Portfolio_project..CovidDeaths Dea
	ON vac.location = Dea.location
	AND vac.date = Dea.date
WHERE dea.continent is not null
)
SELECT *, (TotalVacPerDay/Population)*100
FROM POP

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalVacPerDay
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

