/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


use portfolio
select * 
from portfolio.d.coviddeath
where continent is not null

-- Select Data that we are going to be starting with
select location, date, population, total_cases, new_cases, total_deaths
from portfolio.d.coviddeath
where continent is not null
order by 1,2
								---------------------------------------------

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_deaths, total_cases, (cast(total_deaths as int)/total_cases)*100 DeathPercentage
from portfolio.d.coviddeath
where continent is not null and location like '%Egypt%'
order by 1,2
								-------------------------------------------------
-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population, total_cases, (total_cases/population)*100 PercentPopulationInfected
from portfolio.d.coviddeath
where continent is not null
--where location like '%Egypt%'
order by 1,2
								----------------------------------------------------------
-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) HighestInfectionCount, max((total_cases/population)*100) PercentPopulationInfected
from portfolio.d.coviddeath
where continent is not null
--where location like '%Egypt%'
group by location, population
order by PercentPopulationInfected desc
								-------------------------------------------------------
-- Countries with Highest Death Count per Population
-- by location
select location,  max(total_deaths)TotalDeathsCount 
from portfolio.d.coviddeath
where continent is null
--where location like '%Egypt%'
group by location
order by TotalDeathsCount desc
								
-- by continent
select continent,  max(total_deaths)TotalDeathsCount 
from portfolio.d.coviddeath
where continent is not null
--where location like '%Egypt%'
group by continent
order by TotalDeathsCount desc
										--------------------------------------------
-- GLOBAL NUMBERS

select date,sum(new_cases) TotalCases, sum(cast(new_deaths as bigint)) TotalDeaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 DeathPercentage 
from portfolio.d.coviddeath
where continent is not null
group by date
order by 1,2
										--------------------------------------------
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) RollingPeopleVaccinated
from portfolio.d.coviddeath dea join portfolio.d.covidvaccinated vac
on dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null
order by 2,3
										--------------------------------------------
-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (continent, location,date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) RollingPeopleVaccinated
from portfolio.d.coviddeath dea join portfolio.d.covidvaccinated vac
on dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null
)
select* ,(RollingPeopleVaccinated/ population)*100
from PopvsVac
										--------------------------------------------
-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) RollingPeopleVaccinated
from portfolio.d.coviddeath dea join portfolio.d.covidvaccinated vac
on dea.date = vac.date 
and dea.location = vac.location
--where dea.continent is not null
select* ,(RollingPeopleVaccinated/ population)*100 as PercentageRolling
from #PercentPopulationVaccinated
														---------------------------------------------











