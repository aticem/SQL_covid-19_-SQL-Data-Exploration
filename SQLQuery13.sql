select * from covid_death order by 3,4


--select data that we ar going to be using

select location, date, total_cases, new_cases, total_deaths, population
from covid_death order by 1,2  

-- looking at total_cases vs total_deaths


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage, population
from covid_death order by 1,2  


-- looking at total cases vs population


select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as pop_percentage
from covid_death 
where location like '%turkey%'
order by 1,2 
	


 -- looking at countries with highest infection rate compared to population
  
select location, population, MAX(total_cases) as highest_cases, MAX((total_cases/population)*100) as infection_rate
from covid_death 
--where location like '%turkey%'
group by location, population
order by highest_cases desc


-- showing contries with highest death count per population


select location, max(cast(total_deaths as int)) as total_death
from covid_death 
--where location like '%turkey%'
where continent is not null
group by location
order by total_death desc


-- lets berak things down by continent


select location, max(cast(total_deaths as int)) as total_death
from covid_death 
--where location like '%turkey%'
where continent is null
group by location
order by total_death desc



--showing continents with higest death count per population

select continent, max(cast(total_deaths as int)) as total_death
from covid_death 
--where location like '%turkey%'
where continent is not null
group by continent
order by total_death desc


-- global numbers 


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_Cases)*100 as percentage_death
from covid_death
where continent is not null
order by 1,2 



-- looking at total population vs vaccination

select * from covid_death dea
join covid_vaccin vac
on dea.location = vac.location
and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations from covid_death dea
join covid_vaccin vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations from covid_death dea
join covid_vaccin vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3																																																								


--cerating view to store date for later visualizations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vac
from covid_death dea
join covid_vaccin vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3					


-- use CTE

with PopvsVac ( continent, location, date, population, new_vaccinations,rolling_vac)
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vac
from covid_death dea
join covid_vaccin vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3	
)

select * ,(rolling_vac / population) *100 as rate from PopvsVac order by rate desc


-- Temp table

-- drop table if exists #percentpeoplevaccinated

create table #percentpeoplevaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vac numeric
)

insert into #percentpeoplevaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vac
from covid_death dea
join covid_vaccin vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3	



select * ,(rolling_vac / population) *100 as rate
from #percentpeoplevaccinated


-- creating view to store data for later visualizations

create view percentpeoplevaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vac
from covid_death dea
join covid_vaccin vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3	


---

select * from percentpeoplevaccinated
