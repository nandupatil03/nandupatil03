--select * from covid_death
--order by 3,4

--select * from covid_vaccination
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from covid_death
where location like '%india%'
order by 1,2

--1.TOTAL CASES VS TOTAL DEATH: (BOTH COLUMNS ARE NVARCHAR SO CONVERT IT INTO FLOAT OR INT)
--also likelyhood
SELECT location,date,total_cases,total_deaths,
    CASE 
        WHEN TRY_CONVERT(int, total_cases) = 0 THEN NULL
        ELSE TRY_CONVERT(float, total_deaths) / TRY_CONVERT(float, total_cases)*100
    END AS death_rate
FROM 
    covid_death
	where location like '%india%'
	order by  1,2;

--2.TOTAL CASES VS TOTAL POPULATION: (POPULATION CANNOT BE NULL SO 2 LINE CODE IS ENOGH)
select location,population,date,total_cases,((total_cases/population))*100 as INFECTED_PERCENT
from covid_death

--3.HIGHEST INFECTED COUNTRY:
select location,population, MAX(total_cases) as max_cases,MAX((total_cases/population))*100 as max_INFECTED_PERCENT 
from covid_death
GROUP BY location,population
order by (max_INFECTED_PERCENT) desc

--4.HIGHEST DEATH CASES:
select location,population, MAX(total_deaths) as max_deathcases,MAX((total_deaths/population))*100 as max_death_PERCENT 
from covid_death
where continent is not null 
GROUP BY location,population
order by (max_death_PERCENT) desc

--5.HIGHEST DEATH RATIO BY CONTINENTS:
select continent, max((total_deaths/population))*100 as max_death_PERCENT 
from covid_death
where continent is not null 
GROUP BY continent
order by (max_death_PERCENT) desc

--6.SUM OF NEW CASES AND NEW DEATHS IN WORLD
select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths
from covid_death

--7.SUM RATIO OF NEW CASES AND NEW DEATHS
select location,new_cases,new_deaths,
case
	when sum(new_cases) = 0 then null
	else sum(new_deaths)/sum(new_cases)* 100
end as sum_ratios
from covid_death
group by new_cases,new_deaths,location
order by 1,4 desc

--8.JOIN
select * from covid_death as cov
join covid_vaccination as vac
on cov.date = vac.date 
and cov.location = vac.location

--9.HIGHEST NEW VACCINATION PER DAY
select cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations from covid_death as cov
join covid_vaccination as vac
on cov.date = vac.date 
and cov.location = vac.location
where cov.continent is not null
order by 5 desc

--10.TOTAL NEW VACCINATIONS OF EACH COUNTRY
select cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by cov.location  ) as total_vaccinations_per_location
from covid_death as cov
join covid_vaccination as vac
on cov.date = vac.date 
and cov.location = vac.location
where cov.continent is not null --and
--cov.location like '%jamaica%'
order by cov.location,cov.date

--11.TOTAL VACCINATION VS POPULATION:
--CTE (IN ABOVE WE CANNOT PERFORM RATIO OF VACC VS POP DUE TO NEWELY CREATED OF TOTAL_VACC_PER_LOC,SO IN THIS CASE CTE CAN BE USED)
with vaccvspop (continent,location,date,population,new_vaccinations,total_vaccinations_per_location)
as
(
select cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by cov.location  ) as total_vaccinations_per_location
from covid_death as cov
join covid_vaccination as vac
on cov.date = vac.date 
and cov.location = vac.location
where cov.continent is not null --and
--cov.location like '%jamaica%'
--order by cov.location,cov.date (ORDER BY IS INVALID FOR CTE TABLES)
)
select *,(total_vaccinations_per_location/population) as ratio from  vaccvspop 
order by 7 desc --(ERROR : NULL VALUE OCCURED MEANS WE SHOULD GO FOR CASE STATMENT)

--12.TEMP TABLE (ALL COLUMNNS DATA TYPES SHOULD BE MENTIONED HERE)
drop table if exists #vacvspopu --(IF ANY MODIFICATION FOR TEMP TABLES THEN DROP SHOULD BE USED TO RE-CREATE TEMP TABLES TO RUN IT)
create table #vacvspopu (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations_per_location numeric
)
insert into  #vacvspopu
select cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by cov.location  ) as total_vaccinations_per_location
from covid_death as cov
join covid_vaccination as vac
on cov.date = vac.date 
and cov.location = vac.location
where cov.continent is not null --and
--cov.location like '%jamaica%'
order by cov.location,cov.date --(ORDER BY IS VALID FOR TEMP TABLES)

select *,(total_vaccinations_per_location/population) as ratio from  #vacvspopu 

--13.VIEW TABLE (NEW VIEW IS CREATED ON VIEWS SECTION, VIEW TABLES ARE USED FOR VISULATION)
Create View vaccvspopu as
Select cov.continent,cov.location,cov.date,cov.population,vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by cov.location  ) as total_vaccinations_per_location
from covid_death as cov
join covid_vaccination as vac
on cov.date = vac.date 
and cov.location = vac.location
where cov.continent is not null --and
--cov.location like '%jamaica%'
--order by cov.location,cov.date (ORDER BY IS INVALID FOR VIEW TABLES)

select * 
from  vacvspopu
