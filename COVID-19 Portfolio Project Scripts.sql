Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by location
order by TotalDeathCount DESC


-- Breaking things down by Continent

-- This query will give you the highest death count however it does not include everything. For example North America does not include Canida

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount DESC

-- This query will give you the more accurrate highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount DESC

-- GLOBAL NUMBERS

-- Total Cases vs Total Deaths by Date

Select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by date
Order by 1,2

-- Total Cases vs Total Deaths 

Select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
-- Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select *
From PercentPopulationVaccinated