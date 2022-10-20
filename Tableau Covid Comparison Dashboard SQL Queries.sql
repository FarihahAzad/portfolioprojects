-- Queries used for Covid Comparison Dashboard between U.S. and Bangladesh

-- Create table that includes both U.S. and Bagladesh's Covid Data
drop table if exists Covid_Cases;
create table Covid_Cases
(Location text,
 Population double, 
 Covid_Date date, 
 Covid_Year year, 
 New_Cases double,
 Total_Cases double, 
 New_Deaths text, 
 Total_Deaths double
 );
insert into Covid_Cases(Location, Population, Covid_Date, Covid_Year, New_Cases, Total_Cases, New_Deaths, Total_Deaths)
select location, population, covid_date, covid_year, cast(new_cases as double), total_cases, new_deaths, cast(total_deaths as double) 
from uscovid 
union all 
select location, population, covid_date, covid_year, new_cases, total_cases, new_deaths, cast(total_deaths as double)
from bdcovid ; 

-- testing table
select * from covid_cases
order by location, covid_date asc;

-- TABLEAU QUERIES

-- us covid numbers, sheet 1
 
select location,  max(total_cases) as total_cases, 
max(cast(total_deaths as double)) as total_deaths, max(cast(total_deaths as double))/max(total_cases) * 100 as death_percentage
from covid_cases
Where location like '%states%'
group by location;

-- bd covid numbers, sheet 2
select location,  max(total_cases) as total_cases, 
max(cast(total_deaths as double)) as total_deaths, max(cast(total_deaths as double))/max(total_cases) * 100 as death_percentage
from covid_cases
Where location like '%desh%'
group by location;

-- total deaths counts in the us and bangladesh, sheet 3
select location, max(cast(total_deaths as double)) as total_death_count
from covid_cases
group by location; 

-- percent population infected, sheet 4
Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
From Covid_Cases
Group by Location, Population
; 

-- population percent infected by date
Select Location, Population, covid_date, MAX(total_cases) as Highest_Infection_Count,  
Max((total_cases/population))*100 as Percent_Population_Infected
From Covid_Cases
Group by Location, Population, covid_date
order by Percent_Population_Infected desc 
;
