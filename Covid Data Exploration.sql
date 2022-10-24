/*

COVID-19 IN THE UNITED STATES VS. BANGLADESH DATA EXPLORATION

SKILLS USED: Joins, Alters, Temp Tables, CTE's, Aggregate Functions, Creating Views, Converting Data Types

*/

USE  portfolioproject1;
 
 
-- Select the U.S. data table

SELECT * FROM uscovid; 


-- Rename the date column to covid_date 

ALTER TABLE uscovid
RENAME COLUMN date TO Covid_Date;


-- Total Cases vs. Total Deaths in the United States
-- Shows total death percentage  
 
SELECT location, Covid_Date, total_deaths, total_cases, (total_deaths/total_cases)*100 AS death_percentage FROM uscovid;
  
  
-- Total Cases vs. Population in the United States
-- Shows total percent of the population infected
SELECT location, Covid_Date, population, total_cases, (total_cases/population)*100 AS Percent_Population_Infected FROM uscovid;


-- Highest Infection Count and Percent Population Infected in the United States

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 
AS Percent_Population_Infected FROM uscovid
GROUP BY location,population
ORDER BY Percent_Population_Infected DESC;
-- Nearly 29% of the population has been in infected


-- Percent Population Infected vs. 2020, 2021, and 2022
-- Extract the year from the date 

ALTER TABLE uscovid
ADD Covid_Year year NOT NULL;
SET SQL_SAFE_UPDATES = 0;
UPDATE uscovid
SET Covid_Year = EXTRACT( YEAR FROM Covid_Date);
SELECT * FROM uscovid;


-- Move covid year next to covid date

ALTER TABLE uscovid
MODIFY Covid_YEAR year AFTER Covid_Date; 
SELECT * FROM uscovid;


-- Shows percentage of population infected in the U.S.

SELECT  Covid_year, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM uscovid
GROUP BY Covid_year, Population;


-- From 2020 to 2022 the percent of the population infected jumped from 6% to 28%.
-- A quarter of the U.S. population has been infected by covid.
-- 2020 to 2021 had about a 10% increase. 
-- 2021 to 2022 had about a 12% increase.


-- Total Death Count vs. Year

Select covid_year, population, MAX(CAST(total_deaths as double)) AS TotalDeathCount, SUM(CAST(new_deaths AS DOUBLE)) AS total_deaths
from uscovid
GROUP BY  covid_year, population;
-- Total Death Count in the U.S. reached 1 million after 2 years into the pandemic


-- Shows U.S. death percentage out of those infected 

select location,  max(total_cases) as total_cases, 
max(cast(total_deaths as double)) as total_deaths, max(cast(total_deaths as double))/max(total_cases) * 100 as death_percentage
from uscovid
group by location;
-- U.S. death percentage is about 1.1%


-- SELECT THE BANGLADESH DATA TABLE 

SELECT * FROM bdcovid;


-- Alter the table and covid year column 

ALTER TABLE bdcovid
ADD Covid_Year year NOT NULL;
UPDATE bdcovid
SET Covid_Year = EXTRACT( YEAR FROM Covid_Date);
ALTER TABLE bdcovid
MODIFY Covid_YEAR year AFTER Covid_Date;


-- Shows percentage of population infected in Bangladesh

SELECT  Covid_year, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM bdcovid
GROUP BY Covid_year, Population;
-- About 1.2% of the population has been infected. 
-- Bangladesh population is almost half as much as the U.S. population and has a very small percentage of cases.   


-- Shows death percentage of those infected

select location, max(total_cases) as total_cases, 
max(cast(total_deaths as double)) as total_deaths, max(cast(total_deaths as double))/max(total_cases) * 100 as death_percentage
from bdcovid
group by location;
-- Bangladesh death percentage is about 1.4 deathpercent
  
  
-- JOIN TABLES

SELECT * FROM uscovid us 
JOIN bdcovid bd
ON us.covid_date = bd.covid_date;
-- This join starts the data on march 8,2020 and ends october 11, 2022


-- Using CTE to perform Calculation on Partition By 
-- Shows the total number of vaccinations in the U.S. and Bangladesh
-- Selects the max amount of people vaccinated partitioned by year
-- Shows total percent vaccinated 
 
With Vaccinated_Population (US_Location, US_Population, US_Covid_Date, US_Covid_Year, US_People_Vaccinated, US_Total_People_Vaccinated, 
BD_Location, BD_Population, BD_Covid_Date, BD_Covid_Year, BD_People_Vaccinated, BD_Total_People_Vaccinated)
AS
(
select us.location, us.population, us.covid_date, us.covid_year , us.people_vaccinated,
MAX(CAST(us.people_vaccinated AS DOUBLE)) OVER (PARTITION BY us.covid_year ) AS US_Total_People_Vaccinated,		
	    bd.location, bd.population, bd.covid_date, bd.covid_year, bd.people_vaccinated, 
        MAX(CAST(bd.people_vaccinated AS DOUBLE)) OVER (PARTITION BY bd.covid_year) AS BD_Total_People_Vaccinated
from   uscovid us
join bdcovid bd on us.covid_date=bd.covid_date
)
select US_Location, US_Population, US_Covid_Date, US_Covid_Year, US_People_Vaccinated, US_Total_People_Vaccinated, 
(US_Total_People_Vaccinated/us_population)*100 AS US_Total_Vaccinated_Percentage, 
BD_Location, BD_Population, BD_Covid_Date, BD_Covid_Year, BD_People_Vaccinated, BD_Total_People_Vaccinated,  
(BD_Total_People_Vaccinated/bd_population)*100 BD_Total_Vaccinated_percentage
from Vaccinated_Population;


-- Using Temp Table to perform Calculation on Partition By
-- Shows the total number of vaccinations in the U.S. and Bangladesh
-- Selects the max amount of people vaccinated partitioned by year 

drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated
(US_Location text,
 US_Population double, 
 US_Covid_Date date, 
 US_Covid_Year year, 
 US_People_Vaccinated text, 
 US_Total_People_Vaccinated double, 
 BD_Location text,
 BD_Population double,
 BD_Covid_Date date, 
 BD_Covid_Year year, 
 BD_People_Vaccinated text, 
 BD_Total_People_Vaccinated double);
 insert into PercentPopulationVaccinated(US_Location, US_Population, US_Covid_Date, US_Covid_Year, US_People_Vaccinated, 
 US_Total_People_Vaccinated, BD_Location, BD_Population, BD_Covid_Date, BD_Covid_Year, BD_People_Vaccinated, BD_Total_People_Vaccinated) 
 select us.location, us.population, us.covid_date, us.covid_year , us.people_vaccinated,
MAX(CAST(us.people_vaccinated AS DOUBLE)) OVER (PARTITION BY us.covid_year ) AS US_Total_People_Vaccinated,		
	    bd.location, bd.population, bd.covid_date, bd.covid_year, bd.people_vaccinated, 
        MAX(CAST(bd.people_vaccinated AS DOUBLE)) OVER (PARTITION BY bd.covid_year) AS BD_Total_People_Vaccinated
from   uscovid us
join bdcovid bd on us.covid_date=bd.covid_date;


-- Shows total percent population vaccinated by year in the U.S. and Bangladesh

select distinct US_Covid_Year, US_Location, US_Population,  US_Total_People_Vaccinated, 
(US_Total_People_Vaccinated/us_population)*100 AS US_total_vaccinated_percentage, 
BD_Location, BD_Population,  BD_Covid_Year,  BD_Total_People_Vaccinated,  
(BD_Total_People_Vaccinated/bd_population)*100 BD_total_vaccinated_percentage
from PercentPopulationVaccinated;


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinatedView AS 
select  us.location as US_Location, us.population as US_Population, us.covid_date as US_Covid_Date, 
us.covid_year as US_Covid_Year , us.people_vaccinated as US_People_Vaccinated,
MAX(CAST(us.people_vaccinated AS DOUBLE)) OVER (PARTITION BY us.covid_year ) AS US_Total_People_Vaccinated,		
	     bd.location as BD_Location, bd.population as BD_Poplulation, bd.covid_date as BD_Covid_Date,
         bd.covid_year as BD_Covid_Year, bd.people_vaccinated as BD_People_Vaccinated, 
        MAX(CAST(bd.people_vaccinated AS DOUBLE)) OVER (PARTITION BY bd.covid_year) AS BD_Total_People_Vaccinated
from   uscovid us
join bdcovid bd on us.covid_date=bd.covid_date;
select * from PercentPopulationVaccinatedView;




 
 
 
 
 
 
 

