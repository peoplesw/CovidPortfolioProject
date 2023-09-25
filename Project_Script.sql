
-- Total Cases Vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT locations, dates, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 "Death_Percentage"
FROM public.coviddeaths
ORDER BY 1,2

-- Looking at Total Cases Vs. Population
-- Shows what percentage of the population has gotten covid
SELECT locations, dates, total_cases, new_cases, total_deaths, population, (total_cases/population)*100 "Percent_Population_Infected"
FROM public.coviddeaths
-- WHERE locations like '%States%'
ORDER BY 1,2


-- Looking at Countries with highest infection rate compared to Population
SELECT locations, population, MAX(total_cases) "Highest_Infection_Count", MAX((total_cases/population))*100 "Percent_Population_Infected"
FROM public.coviddeaths
-- WHERE locations like '%States%'
GROUP BY locations, population
ORDER BY "Percent_Population_Infected" desc

-- Showing continents with highest death count
SELECT locations, MAX(total_deaths) "Highest_Death_Count"
FROM public.coviddeaths 
WHERE continent is null
GROUP BY locations
ORDER BY "Highest_Death_Count" desc

-- Global Numbers
SELECT dates, SUM(new_cases) "Total_Cases", SUM(new_deaths) "Total_Deaths"--, SUM(cast(new_deaths as int))/SUM(new_cases)*100 "Death_Percentage"
FROM public.coviddeaths
WHERE continent is not null
GROUP BY dates
ORDER BY 1,2


-- Looking at Total Population Vs. Total Vaccinations
-- Use CTE
With Pop_Vs_Vac (continent, locations, dates, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT dea.continent, dea.locations, dea.dates, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition By dea.locations Order By dea.locations,
							   dea.dates) "Rolling_People_Vaccinated"
FROM public.coviddeaths dea JOIN public.covidvaccinations vac 
ON dea.locations=vac.locations and dea.dates=vac.dates
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT *, (Rolling_People_Vaccinated/population)*100
FROM Pop_Vs_Vac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
continent nvarchar(255),
locations nvarchar(255),
dates datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into
SELECT dea.continent, dea.locations, dea.dates, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition By dea.locations Order By dea.locations,
							   dea.dates) "Rolling_People_Vaccinated"
FROM public.coviddeaths dea JOIN public.covidvaccinations vac 
ON dea.locations=vac.locations and dea.dates=vac.dates
WHERE dea.continent is not null
--ORDER BY 1,2,3

SELECT *, (Rolling_People_Vaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated as
SELECT dea.continent, dea.locations, dea.dates, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition By dea.locations Order By dea.locations,
							   dea.dates) "Rolling_People_Vaccinated"
FROM public.coviddeaths dea JOIN public.covidvaccinations vac 
ON dea.locations=vac.locations and dea.dates=vac.dates
WHERE dea.continent is not null
--ORDER BY 1,2,3


