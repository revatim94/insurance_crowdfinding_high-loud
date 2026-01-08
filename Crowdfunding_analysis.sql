create database project;

use project;
-- 1. Convert Epoch Time to Natural Date
SELECT 
  *, 
   FROM_UNIXTIME(created_at) AS Created_date
FROM projects;
select * from projects;
-- Build Calender table
-- 1. CONVERSION OF EPOCH DATE TO NATURAL DATE --
ALTER TABLE projects ADD COLUMN Created_date DATE;
SET SQL_SAFE_UPDATES=0;
UPDATE projects
SET created_date = FROM_UNIXTIME(created_at, '%Y-%m-%d');
SELECT * FROM projects;
  

# SUCESSFUL DATE #
ALTER TABLE projects ADD COLUMN successful_date DATE;
SET SQL_SAFE_UPDATES=0;
select * from calendar;
-- CREATE CALANDER TABLE --
CREATE TABLE calendar (
    project_id INT,
    created_date DATE
);

INSERT INTO calendar (project_id, created_date)
SELECT p.ProjectID, p.created_date
FROM projects p
JOIN calendar c ON p.ProjectID = c.project_id;

SELECT * FROM calendar;
INSERT INTO calendar (project_id, created_date)
SELECT ProjectID,created_date 
FROM projects;	

-- YEAR --
ALTER TABLE calendar
ADD COLUMN cr_Year INT;
UPDATE calendar
SET cr_Year = YEAR(created_date);

-- MONTH NUMBER -- 
ALTER TABLE calendar
ADD COLUMN cr_MonthNumber INT;
UPDATE calendar
SET cr_MonthNumber = MONTH(created_date);

-- MONTH NAME -- 
ALTER TABLE calendar
ADD COLUMN cr_MonthName VARCHAR(50);
UPDATE calendar
SET cr_MonthName = monthname(created_date);

-- QUARTER --
ALTER TABLE calendar
ADD COLUMN cr_Quarter VARCHAR(50);
UPDATE calendar
SET cr_Quarter = concat('Q',QUARTER(created_date));
SELECT * FROM calendar;
-- YEAR-MONTH -- 
ALTER TABLE calendar
ADD COLUMN cr_YearMonth VARCHAR(50);
UPDATE calendar
SET cr_YearMonth = concat(YEAR(created_date),"-",MONTHNAME(created_date));
SELECT * FROM calendar;


-- WEEKDAY NUMBER -- 
ALTER TABLE calendar
ADD COLUMN cr_WeekdayNumber INT;
UPDATE calendar
SET cr_WeekdayNumber = DAYOFWEEK(created_date);

-- WEEKDAY NAME -- 
ALTER TABLE calendar
ADD COLUMN cr_WeekdayName VARCHAR(50);
UPDATE calendar
SET cr_WeekdayName = DAYNAME(created_date);

-- FINANCIAL MONTH -- 
ALTER TABLE calendar
ADD COLUMN Financial_month VARCHAR(50);

UPDATE calendar
SET Financial_month = CONCAT('FM-',
CASE
 WHEN MONTH(created_date)>=4 THEN MONTH(created_date) -3
 ELSE MONTH(created_date)+9
 END);
SELECT * FROM calendar;

-- FINANCIAL QUARTER -- 
ALTER TABLE calendar
ADD COLUMN Financial_quarter VARCHAR(50);

UPDATE calendar
SET Financial_quarter = CASE 
        WHEN MONTH(created_date) IN (4, 5, 6) THEN 'FQ1'
        WHEN MONTH(created_date) IN (7, 8, 9) THEN 'FQ2'
        WHEN MONTH(created_date) IN (10, 11, 12) THEN 'FQ3'
        WHEN MONTH(created_date) IN (1, 2, 3) THEN 'FQ4'
    END;


--  The Goal amount into USD using the Static USD Rate.
SELECT 
    ProjectID,
    name,
    goal,
    'EUR' AS currency,
    goal * 1.08 AS goal_usd
FROM projects;

--  Projects Overview KPI :
-- Total Number of Projects based on outcome
#Total Number of Projects
select count(ProjectID) as "Total Number of Projects" from projects;

#Total Number of Projects based on outcome
select state, count(projectID) as "Total Number of Projects"
from projects
group by state;
#Total number of projects based on location
select country, count(ProjectID) as "Total Number of Projects"
from projects
group by country;

#Total number of projects based on Category
select 
    c.name,
    COUNT(p.ProjectID) as total_projects
from
 category c
join
 projects p on c.id = p.category_id
 group by
 c.name;
#Total number of project created by year, Quarter, Month
select year(FROM_UNIXTIME(created_at)) AS Year ,
concat("Q",quarter(FROM_UNIXTIME(created_at))) AS Quarter,
Month(FROM_UNIXTIME(created_at)) AS Month,
count(projectID) as "Total Number of Projects" from projects
group by Year,Quarter,Month;

#Successful Project based on:

#Amount Raised
select concat(Round(sum(CASE 
WHEN state = 'successful' THEN usd_pledged
ELSE 0
END)  / 1000000000 ,2),"B") as AmountRaised 
from projects;
#Number of Backers
select count(backers_count) "Number of Backers" from projects 
where state = "successful";
#Avg no. of Days taken
select avg(datediff(FROM_UNIXTIME(successful_at),FROM_UNIXTIME(created_at))) "Avg. days Taken"
from projects
where state = "successful";

#Top successful projects based on no. of backers
select name, backers_count from projects
order by 2 desc
limit 10;

#Top successful projects based on Amount Raised
select name, 
case 
when state = "successful" then pledged
else 0
end as AmountRaised
from projects
order by 2 desc
limit 10;

#percentage of successful projects overall
select concat((sum(case when state = "successful" 
then 1 else 0 end)/ count(*)) * 100,"%") as percentage_successful
from projects;
#Percentage of successful projects by category  
SELECT 
    c.name,
    COUNT(p.projectid) AS total_projects,
    CONCAT(
        ROUND((COUNT(p.projectid) / total.total_count) * 100, 2), '%'
    ) AS percentage_of_total
FROM 
    category c
JOIN 
    projects p ON c.id = p.category_id
JOIN 
    (SELECT COUNT(*) AS total_count FROM projects) total
GROUP BY 
    c.name, total.total_count;
#percentage of succesfulproject by year, Quarter, month
select year(FROM_UNIXTIME(created_at)) AS Year ,
concat("Q",quarter(FROM_UNIXTIME(created_at))) AS Quarter,
Month(FROM_UNIXTIME(created_at)) AS Month,
concat((sum(case when state = "successful" 
then 1 else 0 end)/ count(*)) * 100,"%") as percentage_successful
from projects
group by Year,Quarter,Month;

#percentage of successful projects by goal range

select 
case 
when goal < 2501 then "0-2500"
when goal < 5001 then "0-5000"
when goal < 10001 then "0-10000"
when goal < 20001 then "0-20000"
when goal < 50001 then "0-50000"
when goal < 100001 then "0-100000"
when goal < 200001 then "0-200000"
when goal > 200000 then "200001+"  
end as GoalRange,
concat((sum(case when state = "successful" 
then 1 else 0 end)/ count(*)) * 100,"%") as percentage_successful
from projects
group by goalrange;


