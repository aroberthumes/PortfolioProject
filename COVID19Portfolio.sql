select *
From PortfolioProject..['COVID vaccinations]
Where continent is not null
order by 3,4

--select *
--From PortfolioProject..['COVID deaths]
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['COVID deaths]
order by 1,2

--Looking at Total Cases vs. Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['COVID deaths]
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs. Population
-- Shows percentage of people that have contracted COVID

select location, date, population, total_cases, (total_cases/population)*100 as PopulationWithCOVID
From PortfolioProject..['COVID deaths]
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rates compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..['COVID deaths]
--where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc

-- Countries with Highest Death Count per Population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['COVID deaths]
--where location like '%states%'
Where continent is not null
group by location
order by TotalDeathCount desc

-- Continents by Highest Death Counts per Population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['COVID deaths]
--where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Looking at countries with highest infection rates compared to population

select continent, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..['COVID deaths]
--where location like '%states%'
group by continent, population
order by PercentagePopulationInfected desc


-- Continents by Highest Death Counts per Population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['COVID deaths]
--where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Data

select date, SUM(new_cases) as New_cases, SUM(cast (new_deaths as int)) as New_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['COVID deaths]
--where location like '%states%'
where continent is not null
group by date
order by 1,2

-- Total Global Data

select SUM(new_cases) as New_cases, SUM(cast (new_deaths as int)) as New_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['COVID deaths]
--where location like '%states%'
where continent is not null
order by 1,2


-- COVID Vaccinations

Select *
from PortfolioProject..['COVID deaths] dea
join PortfolioProject..['COVID vaccinations] vac	
	on dea.location = vac.location
	and dea.date = vac.date

-- Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as NewVaccinationsPerDay
--, (NewVaccinationsPerDay/population)
from PortfolioProject..['COVID deaths] dea
join PortfolioProject..['COVID vaccinations] vac	
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using CTE

With PopvsVax (continent, location, date, population, new_vaccinations, NewVaccinationsPerDay)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as NewVaccinationsPerDay
--, (NewVaccinationsPerDay/population)
from PortfolioProject..['COVID deaths] dea
join PortfolioProject..['COVID vaccinations] vac	
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select *, (NewVaccinationsPerDay/population)*100 as PercentageofPopulationVaccinated
from PopvsVax

--Temp Tables

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
NewVaccinationsPerDay numeric
)
Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as NewVaccinationsPerDay
--, (NewVaccinationsPerDay/population)
from PortfolioProject..['COVID deaths] dea
join PortfolioProject..['COVID vaccinations] vac	
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

select *, (NewVaccinationsPerDay/population)*100 as PercentageofPopulationVaccinated
from #PercentPopulationVaccinated

-- Creating view data for Tableau

Use
PortfolioProject
Go
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as NewVaccinationsPerDay
--, (NewVaccinationsPerDay/population)
from PortfolioProject..['COVID deaths] dea
join PortfolioProject..['COVID vaccinations] vac	
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

-- Death Count for Tableau

Use
PortfolioProject
Go
Create View TotalDeathCount as
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['COVID deaths]
--where location like '%states%'
Where continent is not null
group by continent
--order by TotalDeathCount desc

-- Highest Infection rate compared to Population for Tableau

Use
PortfolioProject
Go
Create View InfectionRateComparedtoPopulation as
select continent, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..['COVID deaths]
--where location like '%states%'
group by continent, population
--order by PercentagePopulationInfected desc

-- Continents by Highest Death Counts per Population for Tableau

Use
PortfolioProject
Go
Create View DeathCountyperPopulation as
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['COVID deaths]
--where location like '%states%'
Where continent is not null
group by continent
--order by TotalDeathCount desc
