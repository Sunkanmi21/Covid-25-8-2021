
Select *
From dbo.CovidDeaths
where continent is not null
Order by 3,4


--Select *
--From dbo.[Covid Vaccinations]
--Order by 3,4


-- Select the data that we will be using 

Select continent, date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
where continent is not null
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From dbo.CovidDeaths
Where location like '%Nigeria%'
--AND Continent is not null
Order by 1,2


--Looking at the total Cases vs Population
--Shows percentage of population that got covid
Select continent, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From dbo.CovidDeaths
--Where location like '%Nigeria%'
where continent is not null
Order by 1,2


--Looking at countries with highest infection rates compared to population
--Shows percentage of population that got covid
Select continent, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases)/population)*100 as PercentPopulationInfected
From dbo.CovidDeaths
where continent is not null
Group by continent, population 
Order by 4 desc


Select continent,
population,
max(total_cases) as highestinfectioncount,
max((total_cases)/population)*100 as percentagepopulationinfected
From dbo.CovidDeaths
where continent is not null
group by continent, population
Order by percentagepopulationinfected desc



--Showing countries with the highest death count per population

Select continent,
max(cast(Total_deaths as int)) as TotalDeathsCount
From dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc



--BREAKING IT DOWN BY CONTINENT
--showing continents with the highest death count
Select continent,
max(cast(Total_deaths as int)) as TotalDeathsCount
From dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc



--GLOBAL NUMBERS
--Case per day all around the world
Select date, sum(new_cases) as new_case_perday, 
sum(cast(new_deaths as int)) as new_death_perday, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From dbo.CovidDeaths
--Where location like '%Nigeria%'
where continent is not null
group by date
Order by date, new_case_perday

--total numbers all around the world
Select sum(new_cases) as new_case_perday, 
sum(cast(new_deaths as int)) as new_death_perday, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From dbo.CovidDeaths
--Where location like '%Nigeria%'
where continent is not null
--group by date
Order by new_case_perday, new_death_perday

---JOIN BOTH TABLES 


-- looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeaopleVaccinated
from dbo.CovidDeaths dea
join dbo.[Covid Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- the below is done because RollingPeopleVaccinated can't be used further in the above
--Use CTE

With PopvsVac (continent, location, date, population, new_vaccination, RollingPeaopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeaopleVaccinated
from dbo.CovidDeaths dea
join dbo.[Covid Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeaopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

drop table if exists #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeaopleVaccinated numeric
)

insert into #PERCENTPOPULATIONVACCINATED
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeaopleVaccinated
from dbo.CovidDeaths dea
join dbo.[Covid Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeaopleVaccinated/population)*100
from #PERCENTPOPULATIONVACCINATED


--Creating VIEWS

Create View PERCENTPOPULATIONVACCINATED as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeaopleVaccinated
from dbo.CovidDeaths dea
join dbo.[Covid Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3