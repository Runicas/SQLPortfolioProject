select * from Covid_Deaths
order by 3,4;

--- testas

Select location, date, total_cases, new_cases, total_deaths, population
from Covid_Deaths
order by 1,2;

--- Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Death_Percentage
from Covid_Deaths
where location like '%Lithu%'
order by 1,2;
--- This shows the likelihood of us dying from covid

Select location, date, total_cases, population, round((total_cases/population)*100,2) as Contracted_Pop_Percentage
from Covid_Deaths
where location like '%Lithu%'
order by 1,2;

--This shows the % of population that got covid throughout the course of pandemic

Select location, population,max(total_cases) as Highest_Infection_Count, round(max((total_cases/population))*100,2) as Infection_Percentage
from Covid_Deaths
group by population, location
order by Infection_Percentage DESC;

---Highest infection rate

Select location, max(cast(Total_Deaths as int)) as Total_Death_Count from Covid_Deaths
where continent is not null
group by location
order by Total_Death_Count DESC;

-- MAX covid death count by location, sorted by descending order and continents are filtered out.

Select location, max(cast(Total_Deaths as int)) as Total_Death_Count from Covid_Deaths
where continent is null
group by location
order by Total_Death_Count DESC;

--- Sorted by continent, which includes Canada

Select continent, max(cast(Total_Deaths as int)) as Total_Death_Count from Covid_Deaths
where continent is not null
group by continent
order by Total_Death_Count DESC;

--- Global numbers from this point

Select sum(new_cases)as TOTAL_GLOBAL_CASES,sum(cast(new_deaths as int)) as TOTAL_GLOBAL_DEATHS, round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) as Death_Percentage
from Covid_Deaths
where continent is not null
--group by date
order by 1,2; --- With this query we can see globally it is about 2% death rate

--- Now about vaccinations
--- Total Population vs Vaccination
--- 1st method: I will use CTE for the following calculations

With PopVsVac (Continent, Location, Date, Population, New_Vaccinantions, NEW_TOTAL_VAC)
as(

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location Order by dea.location, dea.date) as NEW_TOTAL_VAC
from Covid_Deaths dea
join Covid_Vaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
)
select *, (NEW_TOTAL_VAC/Population)*100 as Percentage_Of_Vaccinated_People
from PopVsVac

--- 2nd Method with Temporary table
Drop Table if exists #PercentPopVac
Create table #PercentPopVac(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
NEW_TOTAL_VAC numeric)

Insert into #PercentPopVac
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location Order by dea.location, dea.date) as NEW_TOTAL_VAC
from Covid_Deaths dea
join Covid_Vaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 

select *, (NEW_TOTAL_VAC/Population)*100 as Percentage_Of_Vaccinated_People
from #PercentPopVac;

---- Views (can be later used for visualisations)

Create View PopVsVac as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location Order by dea.location, dea.date) as NEW_TOTAL_VAC
from Covid_Deaths dea
join Covid_Vaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 