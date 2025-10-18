Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


--Looking at Total Cases VS Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at Total Cases vs Population
--Shows What percentage of population got Covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where Continent is not null
Group by Location
Order by TotalDeathCount desc


--	LET'S BREAK THINGS DOWN BY CONTINENT

Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where Continent is not null
Group by Continent
Order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where Continent is not null
Group by Continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By Date
Order by 1,2

--Looking at total population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   Order by  2, 3


   --USE CTE

   With PopvsVac(continent, location, date, Population, New_Vaccination, RollingPeopleVaccinated)
   as
(
   Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --Order by  2, 3
 )
 Select* , (RollingPeopleVaccinated/Population)*100
 From PopvsVac


 --TEMP TABLE
 DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
  where dea.continent is not null
   --Order by  2, 3
   Select*, (RollingPeopleVaccinate/Population)*100
   From #PercentPopulationVaccinated


 --  Creating View to store data for later visualisation

 Create view PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date)as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
  where dea.continent is not null
   --Order by  2, 3

   select*
   from PercentPopulationVaccinated