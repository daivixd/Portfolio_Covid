/*
Covid 19, Exploración de datos
Habilidades implementadas: Joins, CTE's, Tablas temporales, Funciones, Vistas, Convertir tipos de datos
*/
Select *
From CovidDeaths
Where continent is not null 
order by 3,4

-- Seleccionamos los datos con los que vamos a comenzar

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2

-- Mostrando total de casos vs total de muertes
-- Mostrando la probabilidad de morir si se contrae covid en Ecuador

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths 
where Location = 'Ecuador'
and continent is not null
order by 1, 2

-- Total de casos vs población
-- Muestra la cantidad de población infectada por el Covid

select Location, date, population, total_cases,(total_cases/population)*100 as PopulationInfected
from CovidDeaths 
where Location = 'Ecuador' 
order by 1, 2

-- Paises con un alto porcentaje de infección en comparación a su población

SELECT Location, Population, Max(total_cases) AS hightestInfectionCount, Max((Total_cases/population))*100 as PercentPopulationInfected 
from CovidDeaths
-- where location = 'Ecuador'
group by location, population 
order by PercentPopulationInfected DESC

-- Paises con altas tasas de muerte por población

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
-- where location = 'Ecuador'
where continent is not null
Group by Location 
order by TotalDeathCount desc

-- Desglose por continente

-- Continentes con mayor tasa de muertes por población

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths 
where continent is not null
Group by continent
order by TotalDeathCount desc

-- A nivel Global

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, CASE WHEN SUM(new_cases) = 0 THEN 0 ELSE SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 END AS DeathPercentage
FROM CovidDeaths
-- where location = 'Ecuador'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

-- Total de población VS vacunados
-- Total de población que ha recibido al menos 1 dosis de la vacuna

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccionations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Uso de CTE para ejecutar el calculo en el posterior query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccionations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

-- Usando tablas temporales para ejecutar el calculo del anterior query

create table #PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccionations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creación de vista

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
join CovidVaccionations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null