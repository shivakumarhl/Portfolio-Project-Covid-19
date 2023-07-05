--COVID19 DATA EXPLORATION

SELECT * FROM CD 
WHERE continent is not null
order by 3,4

--Select Data that we are going to be starting with

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM CD
where continent is not NULL
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
FROM CD
where location = 'india' and continent is not NULL
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location,date,population,total_cases,(total_cases/population)*100 as
PercentPopulationInfected
FROM CD
--where location = 'india'
where continent is not NULL
order by 1,2

--Countries with Highest Infection Rate compared to Population

SELECT location,population,MAX(total_cases),MAX((total_cases/population))*100 as 
PercentPopulationInfected
FROM CD
--where location = 'india'
where continent is not NULL
Group by location,population
order by PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT location,MAX(CAST(total_deaths AS int)) AS Totaldeathcount
FROM CD
--where location = 'india'
where continent is not NULL
Group by location
order by Totaldeathcount DESC

--To be precise in retriving the data of whole world and continents

SELECT location,MAX(CAST(total_deaths AS int)) AS Totaldeathcount
FROM CD
--where location = 'india'
where continent is NULL
Group by location
order by Totaldeathcount DESC

---- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent,MAX(CAST(total_deaths AS int)) AS Totaldeathcount
FROM CD
--where location = 'india'
where continent is not NULL
Group by continent
order by Totaldeathcount DESC

--Global numbers

SELECT date,SUM(new_cases) AS Totalcases,SUM(CAST(new_deaths AS int)) AS Totaldeaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Deathpercentage
FROM CD
WHERE continent is NOT NULL
GROUP BY date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int))over (partition by cd.location ORDER BY cd.location, 
CD.date) as RollingPeopleVaccinated
FROM CD
JOIN CV
ON CD.location=CV.location
and CD.date = CV.date
WHERE CD.continent is NOT NULL
ORDER BY 2,3

--Using CTE to perform Calculation on Partition By in previous query

with popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int))over (partition by cd.location ORDER BY cd.location, 
CD.date) as RollingPeopleVaccinated
FROM CD
JOIN CV
ON CD.location=CV.location
and CD.date = CV.date
WHERE CD.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM popvsvac


---- Using Temp Table to perform Calculation on Partition By in previous query

DROP table if exists #percentpopulationvaccinted
create  table #percentpopulationvaccinted
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationvaccinted
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int))over (partition by cd.location ORDER BY cd.location, 
CD.date) as RollingPeopleVaccinated
FROM CD
JOIN CV
ON CD.location=CV.location
and CD.date = CV.date
WHERE CD.continent is NOT NULL
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #percentpopulationvaccinted

--Creating View to store data for later visualizations

create view percentpopulationvaccinated as
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int))over (partition by cd.location ORDER BY cd.location, 
CD.date) as RollingPeopleVaccinated
FROM CD
JOIN CV
ON CD.location=CV.location
and CD.date = CV.date
WHERE CD.continent is NOT NULL
--ORDER BY 2,3















