# SQLPond
For dipping your toes into the SQL Pond!

This repository is filled with examples of SQL code that can be used to build and explore data, focused on commonly used data in the State of Minnesota.

## SQL Playgrounds
Want to test out this code? Try using one of the following:
1. http://sqlfiddle.com/ : Has worked some tries, not so much others. Note you have to build the full schema (including inserts) before doing queries. When successful, links will be posted below.
2. https://www.w3schools.com/sql/trysql.asp?filename=trysql_create_table : build a db in your browser (SQLite back end). Kind of tedious (inserts only one at a time for example), but works and has a quick Restore function

### SQL Fiddle Links
1. [A unique list of cities](http://sqlfiddle.com/#!18/da6d9/7/0) with manipulated names based on various conditions

### Formatted SQL Exercises
```SQL
/*Build and query a database of some common cities and counties in Minnesota
This file is the space where we build and test this concept with SQL hints in an IDE. When we're finished,
we dump the SQL into the readme for nicer formatting.
 */

/******BEGIN BUILD SCHEMA *********/
--create the county table
CREATE TABLE COUNTY(
	COUNTYFIPS smallint NOT NULL,
	CTY_NAME varchar(20) NULL
)

--create the CTU table
CREATE TABLE CTU(
    GNISTXT varchar(8) NOT NULL,
	FEATNAME varchar(40) NULL,
    CTUTYPE varchar(24) NULL,
	CTYNUM varchar(3) NULL
)

--Insert values into COUNTY table (one at a time at W3schools)
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27003,'Anoka');
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27053,'Hennepin');
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27145,'Stearns');
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27123,'Ramsey');
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27021,'Cass');
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27147,'Steele');

--Insert values into the CITY table (one at a time at W3schools)
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02396471','Saint Anthony','City','053');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02396471','Saint Anthony','City','123');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02396472','Saint Anthony','City','145');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('00663943','Deerfield','Township','021');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('00663944','Deerfield','Township','147');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('00663487','Avon','Township','145');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02394043','Avon','City','145');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02394183','Blaine','City','003');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02394183','Blaine','City','123');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02395261','North Saint Paul','City','123');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02396511','Saint Paul','City','123');
/******END BUILD SCHEMA *********/


/******INDIVIDUAL QUERIES *********/
--Query the COUNTY table with some basic manipulations
SELECT 
COUNTYFIPS AS 'CODE'
,CTY_NAME AS 'NAME'
FROM [COUNTY]

--Query the COUNTY table and mod the name column (using || for SQL Lite concatenation)
SELECT 
COUNTYFIPS AS 'CODE'
--,CTY_NAME || ' County' AS 'NAME' --uses SQL Lite concatenation method, for w3schools
,CTY_NAME + ' County' AS 'NAME' --SQL Server syntax, for sqlfiddle.com
FROM [COUNTY]

--Query the CTU table with some manipulations
SELECT
'27' + CTYNUM + GNISTXT AS GNISID
,CASE WHEN CTUTYPE = 'Township' THEN FEATNAME + ' Twp.'
	WHEN GNISTXT = '02396471' THEN 'St. Anthony Village'
	ELSE FEATNAME
END AS 'NAME'
FROM [CTU]

--Join the two tables to see how all columns look together
SELECT * FROM [CTU]
LEFT JOIN [COUNTY] ON [CTU].[CTYNUM]+27000 = [COUNTY].[COUNTYFIPS]

--Now change some columns to get a customized view
SELECT
CTU.FEATNAME
,CTU.CTUTYPE AS TYPE
,COUNTY.COUNTYFIPS
,COUNTY.CTY_NAME + ' County' AS COUNTY
FROM [CTU]
LEFT JOIN [COUNTY] ON [CTU].[CTYNUM]+27000 = [COUNTY].[COUNTYFIPS]

--Let's pull that all together
SELECT 
'27' + CTU.CTYNUM + CTU.GNISTXT AS GNISID
,CASE WHEN CTU.CTUTYPE = 'Township' THEN CTU.FEATNAME + ' Twp.'
	WHEN CTU.GNISTXT = '02396471' THEN 'St. Anthony Village'
	ELSE CTU.FEATNAME
END AS 'NAME'
,CTU.CTUTYPE AS TYPE
,COUNTY.COUNTYFIPS
,COUNTY.CTY_NAME AS COUNTY
FROM [CTU]
LEFT JOIN [COUNTY] ON [CTU].[CTYNUM]+27000 = [COUNTY].[COUNTYFIPS]

--What if we want to know more about some duplicate names?
SELECT
FEATNAME
,COUNT(FEATNAME) AS COUNT
FROM [CTU]
GROUP BY FEATNAME
HAVING COUNT(FEATNAME) > 1

--so if we wanted to qualify township names with county names:
SELECT 
'27' + CTU.CTYNUM + CTU.GNISTXT AS GNISID
,CASE WHEN DUPES.FEATNAME IS NOT NULL AND CTU.CTUTYPE = 'Township' THEN CTU.FEATNAME + ' Twp.' + ' ('+COUNTY.CTY_NAME+')'
	WHEN DUPES.FEATNAME IS  NULL AND CTU.CTUTYPE = 'Township' THEN CTU.FEATNAME + ' Twp.'
	WHEN CTU.GNISTXT = '02396471' THEN 'St. Anthony Village'
	ELSE CTU.FEATNAME
END AS 'NAME'
,CTU.CTUTYPE AS TYPE
,COUNTY.COUNTYFIPS
FROM [CTU]
LEFT JOIN [COUNTY] ON [CTU].[CTYNUM]+27000 = [COUNTY].[COUNTYFIPS]
LEFT JOIN (SELECT
	FEATNAME --note we only want the feature name, don't need the count
	FROM [CTU]
	WHERE [CTU].CTUTYPE = 'Township' --note we only care about townships
	GROUP BY FEATNAME
	HAVING COUNT(FEATNAME) > 1) AS DUPES ON CTU.FEATNAME = DUPES.FEATNAME


```