select * from portfolio_project..CovidDeaths
where continent is not null
order by 3,4


select * from portfolio_project..Covidvaccinations
order by 3,4

--Select Data that we are going to be using: 

Select Location, date, total_cases, new_cases, total_deaths,
population
From portfolio_project..CovidDeaths
where continent is not null
order by 1,2 

--Total cases vs Total Deaths: [Death_percentage] probability of dying 
Select Location, date, total_cases,  total_deaths, 
(total_deaths/total_cases)* 100 as [Death Percentage ]
From portfolio_project..CovidDeaths
Where location Like '%Canada%'
where continent is not null
order by 1,2 

---Total Cases vs Population: percentage of population infected with Covid
Select Location, date,  population, total_cases,
(total_cases/population)* 100 as [Cases Percentage ]
From portfolio_project..CovidDeaths
--Where location Like '%Canada%'
order by 1,2 

--Countries with highest infection rate compared to population
Select Location,  population, Max(total_cases) as [Highest inflection count],
Max((total_cases/population))* 100 as [ Percentage population inflected  ]
From portfolio_project..CovidDeaths
--Where location Like '%Canada%'
Group by population, location
order by [ Percentage population inflected  ] desc

---Countries with highest death count per population
Select Location, Max(cast(total_deaths as Int)) as TotalDeathCount  
From portfolio_project..CovidDeaths
--Where location Like '%Canada%'
where continent is not null
Group by location
order by TotalDeathCount  desc

---Looking it down from Continent

Select location, Max(cast(total_deaths as Int)) as TotalDeathCount  
From portfolio_project..CovidDeaths
--Where location Like '%Canada%'
where continent is  null
Group by location
order by TotalDeathCount  desc



---Continents with highest Death Count per population

Select continent, Max(cast(total_deaths as Int)) as TotalDeathCount  
From portfolio_project..CovidDeaths
--Where location Like '%Canada%'
where continent is not null
Group by continent
order by TotalDeathCount  desc


---GLobal numbers: covid cases across the globe at the very first beginning
Select Date,  sum(new_cases) as totalNewcases, SUM(cast(new_deaths as int)) as totalNewDeaths, 
SUM(cast(new_deaths as int)) /sum(new_cases)*100 as [Death Percentage ]
From portfolio_project..CovidDeaths
--Where location Like '%Canada%'
where continent is not null
Group by date
order by 1,2 

---Global figures of cases and deaths

Select sum(new_cases) as totalNewcases, SUM(cast(new_deaths as int)) as totalNewDeaths, 
SUM(cast(new_deaths as int)) /sum(new_cases)*100 as [Death Percentage ]
From portfolio_project..CovidDeaths
--Where location Like '%Canada%'
where continent is not null
order by 1,2 


---Total population vs vaccinations
--USE CTE
with popvsVac (Continent, location, date, population, new_vaccinations, rollingvaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, Sum(Convert(int,vac.new_vaccinations)) 
OVER (partition by dea.location order by dea.location, dea.date ) as rollingvaccinated

From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rollingvaccinated/population)*100
FROM popvsVac


--Temp table

create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric, 
new_vaccinations numeric,
rollingvaccinated numeric
)
Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, Sum(Convert(int,vac.new_vaccinations)) 
OVER (partition by dea.location order by dea.location, dea.date ) as rollingvaccinated

From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *, (rollingvaccinated/population)*100
FROM #percentpopulationvaccinated

--Creating view to store data for later visualizations

Create view percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, Sum(Convert(int,vac.new_vaccinations)) 
OVER (partition by dea.location order by dea.location, dea.date ) as rollingvaccinated

From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select *
FRom percentpopulationvaccinated