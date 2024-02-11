select *from 
PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--countries with highest infection rate compared to population
select location, population, max(total_cases) as highestInfectionCount, MAX(total_cases/population) * 100 as
PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 desc


--countries with highest death count per population
select location, population, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 3 desc

--continents with highest death count per population
select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- breaking global level
-- New cases at each day
select date, sum(new_cases) as CasesByDate, SUM(new_deaths) as DeathsByDate, SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
group by date
order by 1

select sum(new_cases) as CasesByDate, SUM(new_deaths) as DeathsByDate, SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--group by date
order by 1