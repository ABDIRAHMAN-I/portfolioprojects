
select * 
from portfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select * 
--from portfolioProject..CovidVaccinations
--order by 3,4

--select data we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- looking at the total cases vs total deaths 
-- shows likelihood of dying if you contract covid in your country 

select location, date, total_cases,total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from portfolioProject..CovidDeaths
where continent is not null
--where location = 'united states'
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid 

select location, date, population, total_cases, (total_cases / population)*100 as percentpopulationinfected
from portfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location,population, max(total_cases)as highestinfectioncount, max((total_cases / population))*100 as percentpopulationinfected
from portfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
group by location,population
order by percentpopulationinfected desc

-- showing countries with highest death count per population 

select location,max(total_deaths) as totaldeathcount
from portfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
group by location
order by totaldeathcount desc


-- LETS BREAK THINGS DOWN BY CONTINENT

-- showing continents with highest death count per population 

select continent,max(total_deaths) as totaldeathcount
from portfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
group by continent
order by totaldeathcount desc


-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(CONVERT(int,new_deaths))/sum(new_cases)*100 as DeathPercentage
from portfolioProject..CovidDeaths
-- where location = 'united states'
where continent is not null and new_cases != 0
group by date
order by 1,2

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
 dea.date) as Rollingpeoplevaccinated
 --,(Rollingpeoplevaccinated/population)*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null 
order by 1, 2, 3


-- USE CTE

with popvsvac (continent, location, date, population,new_vaccinations, Rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
 dea.date) as Rollingpeoplevaccinated
 --,(Rollingpeoplevaccinated/population)*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null -- and dea.location = 'albania'
--order by 2, 3
)

select *, (Rollingpeoplevaccinated/population)*100
from popvsvac


-- TEMP TABLE	

DROP table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated
(
continent nvarchar (255), 
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
 dea.date) as Rollingpeoplevaccinated
 --,(Rollingpeoplevaccinated/population)*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null -- and dea.location = 'albania'
--order by 2, 3

select *, (Rollingpeoplevaccinated/population)*100
from #PercentpopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create view PercentpopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
 dea.date) as Rollingpeoplevaccinated
 --,(Rollingpeoplevaccinated/population)*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null -- and dea.location = 'albania'
--order by 2, 3


select *
from PercentpopulationVaccinated