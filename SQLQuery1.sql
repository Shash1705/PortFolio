Select*
From Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4

--Select*
--From Portfolio_Project..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, population, total_deaths
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total_Cases v/s Total_Deaths
-- Shows the likelihood of dying if you contract covid in your country.

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null
--Where location like '%india%'
order by 1,2

-- Looking at total cases vs Population
-- Shows the percentage of population who got covid

Select Location, date, population , total_cases, (total_cases/population)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null  
--where location like '%india%'
order by 1,2

---Looking at countries with highest infection rate compared to population

Select Location, population , 
MAX(total_cases) as Highest_Infection_Count , 
MAX((total_cases/population))*100 as Percentage_population_infected

From Portfolio_Project..CovidDeaths

where continent is not null
--where location like '%india%'

group by Location, Population 
order by Percentage_population_infected desc

-- Looking at countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count 
From Portfolio_Project..CovidDeaths
--where location like '%india%'
where continent is not null
group by Location
order by Total_Death_Count desc

-- Breaking things down by continent and not location now.

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count 
From Portfolio_Project..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by Total_Death_Count desc

-- Showing the continent with highest death couunt

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count 
From Portfolio_Project..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by Total_Death_Count desc


-- Global Numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage

  From Portfolio_Project..CovidDeaths
   where continent is not null
    --group by date
	--Where location like '%india%'
	  order by 1,2


-- Joining two tables
Select*
From Portfolio_Project.. CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date

 -- Looking at total population vs Vaccinated population
 Select  dea.continent, dea.location,dea.date, vac.new_vaccinations , dea.population,
 SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollcount
 --, (rollcount/population)*100
From Portfolio_Project.. CovidDeaths dea
Join Portfolio_Project..CovidVaccinations Vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null 
 order by 2,3

 --Use CTE

 With PopvsVac( Continent, Location, Date, Population,new_vaccinations, rollcount )
 as 
 (
 Select  dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations , 
 SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollcount
 --, (rollcount/population)*100
From Portfolio_Project.. CovidDeaths dea
Join Portfolio_Project..CovidVaccinations Vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null 
-- order by 2,3
 )
 Select*, (rollcount/Population)*100
 From PopvsVac

 ---TEMP Table

 DROP table if exists #PopulationVaccinated
 Create Table #PopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccination numeric,
 rollcount numeric
 )

 Insert Into #PopulationVaccinated
  Select  dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations , 
 SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollcount
 --, (rollcount/population)*100
From Portfolio_Project.. CovidDeaths dea
Join Portfolio_Project..CovidVaccinations Vac
 on dea.location=vac.location
 and dea.date=vac.date
-- where dea.continent is not null 
-- order by 2,3

Select*, (rollcount/Population)*100
 From #PopulationVaccinated

 -- Creating View to store data for LaterVisualisation

 Create view PercentPopulationVaccinated as
 Select  dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations , 
 SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollcount
 --, (rollcount/population)*100
From Portfolio_Project.. CovidDeaths dea
Join Portfolio_Project..CovidVaccinations Vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

Select*
From PercentPopulationVaccinated