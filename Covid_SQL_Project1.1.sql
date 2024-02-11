select *from PortfolioProject..CovidVaccination

alter table CovidVaccination
alter column new_vaccinations float

--Looking at total population vs Vaccinated population
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3 


-- USE CTE
with popVSvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population) * 100
From popVSvac


--Temp table
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population) * 100
From #PercentagePopulationVaccinated


-- Creating views
create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


Select *from PercentagePopulationVaccinated