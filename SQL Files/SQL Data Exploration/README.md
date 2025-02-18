# Overview
These are T-SQL queries are from the guided Covid SQL exploration project by Alex the Analyst. I followed along and added comments that are different from the video's to solidify my understanding.<br/><br/>
=======
These are T-SQL queries are from the guided Covid SQL EDA project by Alex the Analyst. I followed along and added comments that are different from the video's to solidify my understanding.<br/><br/>
>>>>>>> 089024f01034f6f2a8bb63a4f2ff3b010927717e:SQL Files/SQL EDA/README.md
The data was datasets were stored in two separate excel worbook files, "CovidDeaths.xlsx" and "CovidVaccinations.xlsx" and were uploaded into SQL Server via
SSMS's "SQL Server 2022 Import and Export Data" wizard.<br/><br/>

# T-SQL Functions, Clauses, and Arithmetic Used

## CAST
This function converts an expression of one data type to another.<br/>
Is also an ANSI SQL function, so it can be used in different flavors of SQL. <br/><br/>
Syntax:<br/>
`CAST(expression as data_type)`

We used this function after realizing some of the numeric fields were uploaded as NVARCHAR during importation to SQL Server.
We had to convert the data types because we were not able to perform arithmetic calculations on the fields. 

Example:<br/>
--Shows total_cases, total_deaths, death_percentage across the entire globe.<br/>
SELECT `CAST(new_deaths as INT)`<br/>
FROM COVIDPortfolioProject.dbo.CovidDeaths <br/>

## CONVERT
This function also converts an expression of one data type to another, but has the optional "style" parameter that can change the format of the data displayed.<br/><br/>
Syntax:<br/>
`CONVERT(data_type, expression [, style])`

We used this function for the same reason as CAST

Example:<br/>
SELECT `CONVERT(INT, vac.new_vaccinations)`
FROM COVIDPortfolioProject.dbo.CovidDeaths dea <br/>

## SUM
This function calculates the sum of all values<br/><br/>
Syntax:<br/>
SUM(expression)<br/>

Example:<br/>
--Shows total new cases.<br/>
SELECT SUM(new_cases) as total_new_cases<br/> 
FROM COVIDPortfolioProject.dbo.CovidDeaths<br/>

## SUM() OVER()
This function also calculates the sum of all values, but as a running sum.<br/>
In other words, instead of just showing the sum, it shows the sum at each progressive step until the final sum is reached.<br/>

Example:<br/>
SELECT <br/>
&emsp; --Calculates running sum of new vaccinations <br/> 
&emsp; location, SUM(CONVERT(INT, dea.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.date)<br/>
&emsp;	AS running_sum_new_vaccinations <br/>
FROM COVIDPortfolioProject.dbo.CovidDeaths dea <br/>
where dea.continent IS NOT NULL

## MAX
Retrieves the maximum value of all values <br/><br/>
Syntax:<br/>
MAX(expression) <br/>

Example:<br/>
SELECT MAX(new_cases) as max_new_cases<br/> 
FROM COVIDPortfolioProject.dbo.CovidDeaths<br/>

## DROP VIEW IF EXISTS
This clause drops view from the database if it already exists <br/>

Syntax: <br/>
DROP TABLE IF EXISTS TableName <br/>

## WITH
Allows you to create a common table expression (type of temporary table) that is only available for the duration of the query. <br/>

Syntax: <br/>
WITH MyCTE[(column1 [, column2, column3, ...])] AS <br/>
( <br/>
&emsp; SELECT column1 <br/>
&emsp;FROM MyTable <br/>
) <br/>
SELECT * <br/>
FROM MyCTE <br/>

## CREATE TABLE
This creates a temp table, a table that lasts for the duration of a session or transaction. <br/>
It is stored physically in the database/disk and can be used like a regular table. <br/>

Syntax:<br/>
CREATE TABLE #MyTempTable

## DROP TABLE IF EXISTS
This clause drops table/temp table from the database if it already exists <br/>

Syntax: <br/>
DROP TABLE IF EXISTS TableName <br/>

## CREATE VIEW
Creates a view in the database.<br/>
A view is a query that is stored in the database, but can be accessed like a table. <br/>
Every time the view is accessed the query is executed again. <br/>
View can be stored physically in database like regular table as materialized view, but <br/>
it will not update if underlying table is changed, by default. <br/>

Syntax:<br/>
CREATE VIEW MyView <br/>
SELECT important_category1, sum(metric) <br/>
FROM MyTable <br/>
GROUP BY important_category1 <br/>

## DROP VIEW IF EXISTS
This clause drops view from the database if it already exists. <br/>

Syntax: <br/>
DROP VIEW IF EXISTS ViewName <br/>

## GROUP BY
Groups rows of the same values into summary group. <br/>
Columns that are not grouped must be contained in aggregate function. <br/>

Syntax: <br/>
SELECT important_category1, sum(metric) <br/>
FROM MyTable <br/>
GROUP BY important_category1 <br/>

## *
Multiplication operator in T-SQL. <br/>

Example: <br/>
SELECT 2*2 -- Outputs 4.

## /
Division operator in T-SQL. <br/>

Example: <br/>
SELECT 2/2 -- Outputs 1. <br/><br/>

# Temp Table vs View vs CTE
All three can be used for quick access to a subset of data, but each have different use-cases:

## Temp Table
Temp tables are used to for storing and reusing intermediate results.

For example, the contents of a temp table can change through intermediate steps throughout a process.

## View 
Are used for query reuse in visualization software such as Tableau to access important summary data.

## CTE
Are used to query a subset of data, but can be used recursively for complex calculations.
