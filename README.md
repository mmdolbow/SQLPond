# SQLPond
For dipping your toes into the SQL Pond!

This repository is filled with examples of SQL code that can be used to build and explore data, focused on commonly used data in the State of Minnesota.

## More Docs
- For learning how to query file-based geodatabases (FGDB) with SQL, see the [File-based Geodatabase (FGDB) Queries](fgdb_queries.md) document.
- Coming soon: intermediate SQL in ArcGIS Pro with GeoPackages

## SQL Playgrounds
Want to test out this code? Try using one of the following:
1. http://sqlfiddle.com/ : Has worked some tries, not so much others. Note you have to build the full schema (including inserts) before doing queries. When successful, links will be posted below.
2. https://www.w3schools.com/sql/trysql.asp?filename=trysql_create_table : build a db in your browser (SQLite back end). Kind of tedious (inserts only one at a time for example), but works and has a quick Restore function

### SQL Fiddle Links
1. [A unique list of cities](http://sqlfiddle.com/#!18/da6d9/7/0) with manipulated names based on various conditions

### Formatted SQL Exercises
In the sections below, you'll find SQL you can copy and paste into a website like sqlfiddle.com (be sure to switch to MS SQL Server style!). Build the schema first, then query it.

#### Build and Query County and City database
SQL to build and query a database of some common cities and counties in Minnesota.
##### Build Schema
```SQL
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

--Insert values into COUNTY table
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27003,'Anoka');
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27053,'Hennepin');
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27145,'Stearns');
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27123,'Ramsey');
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27021,'Cass');
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27147,'Steele');

--Insert values into the CITY table
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
```
##### Query the city and county  tables
The following sections are individual queries you can use against the above schema. Try them out!
```SQL
--Query the COUNTY table with some basic manipulations
SELECT 
COUNTYFIPS AS 'CODE'
,CTY_NAME AS 'NAME'
FROM [COUNTY]
```
```SQL
--Query the COUNTY table and mod the name column
SELECT 
COUNTYFIPS AS 'CODE'
,CTY_NAME + ' County' AS 'NAME'
FROM [COUNTY]
```
```SQL
--Query the CTU table with some manipulations
SELECT
'27' + CTYNUM + GNISTXT AS 'GNISID'
,CASE WHEN CTUTYPE = 'Township' THEN FEATNAME + ' Twp.'
	WHEN GNISTXT = '02396471' THEN 'St. Anthony Village'
	ELSE FEATNAME
END AS 'NAME'
FROM [CTU]
```
```SQL
--Join the two tables to see how all columns look together
SELECT * FROM [CTU]
LEFT JOIN [COUNTY] ON [CTU].[CTYNUM]+27000 = [COUNTY].[COUNTYFIPS]
```
```SQL
--Now change some columns to get a customized view
SELECT
CTU.FEATNAME
,CTU.CTUTYPE AS TYPE
,COUNTY.COUNTYFIPS
,COUNTY.CTY_NAME + ' County' AS COUNTY
FROM [CTU]
LEFT JOIN [COUNTY] ON [CTU].[CTYNUM]+27000 = [COUNTY].[COUNTYFIPS]
```
```SQL
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
```
```SQL
--What if we want to know more about some duplicate names?
SELECT
FEATNAME
,COUNT(FEATNAME) AS 'COUNT'
FROM [CTU]
GROUP BY FEATNAME
HAVING COUNT(FEATNAME) > 1
```
```SQL
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

#### Build and Query Schools and School District database
SQL to build and query a database of some schools and districts in Minnesota.

##### Build Schema
```SQL
/******BEGIN BUILD SCHEMA *********/
--Create the school district table
CREATE TABLE SCHOOL_DISTRICT(
	ORGID numeric(12, 0) NULL,
	NAME nvarchar(50) NULL,
    TYPE nvarchar(2) NULL,
    NUMBER nvarchar(4) NULL
)

--Add records to the school district table
INSERT INTO SCHOOL_DISTRICT (ORGID,NAME,TYPE,NUMBER) VALUES (10001000000,'Aitkin','01','0001');
INSERT INTO SCHOOL_DISTRICT (ORGID,NAME,TYPE,NUMBER) VALUES (30001000000,'Minneapolis','03','0001');
INSERT INTO SCHOOL_DISTRICT (ORGID,NAME,TYPE,NUMBER) VALUES (10625000000,'St. Paul','01','0625');
INSERT INTO SCHOOL_DISTRICT (ORGID,NAME,TYPE,NUMBER) VALUES (10621000000,'Mounds View','01','0621');
INSERT INTO SCHOOL_DISTRICT (ORGID,NAME,TYPE,NUMBER) VALUES (12909000000,'Rock Ridge','01','2909');

--Create the schools table
CREATE TABLE SCHOOLS(
	ORGID numeric(12, 0) NULL,
	SCHNAME nvarchar(50) NULL,
	ADDRESS nvarchar(40) NULL,
	CITY nvarchar(35) NULL,
	ZIP nvarchar(10) NULL,
	ALT_NAME nvarchar(50) NULL
)

--Add records to the schools table
--start with district offices
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP,ALT_NAME) VALUES (30001000000,'Minneapolis District Office','1250 West Broadway Ave','Minneapolis','55411','Minneapolis')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP,ALT_NAME) VALUES (12909000000,'Rock Ridge District Office','411 5th Ave S','Virginia','55792','Rock Ridge')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP,ALT_NAME) VALUES (10625000000,'St. Paul District Office','360 Colborne St','Saint Paul','55102','St. Paul')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP,ALT_NAME) VALUES (10621000000,'Mounds View District Office','4570 Victoria St N','Shoreview','55126','Mounds View')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP,ALT_NAME) VALUES (10001000000,'Aitkin District Office','306 2nd St NW','Aitkin','56431','Aitkin')

--Some Mpls schools (notice since we don't mention ALT_NAME, we can just skip it)
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (30001309000,'Anwatin Middle','256 Upton Ave S','Minneapolis','55405')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (30001249000,'Bryn Mawr','252 Upton Ave S','Minneapolis','55405')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (30001136000,'Kenwood','2013 Penn Ave S','Minneapolis','55405')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (30001130000,'Hiawatha Elem','4201 42nd Ave S','Minneapolis','55406')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (30001104000,'Lake Harriet Lower','4030 Chowen Ave S','Minneapolis','55410')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (30001360000,'Roosevelt Senior High','4029 28th Ave S','Minneapolis','55406')

--Sample schools for the remaining districts
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (10001001000,'Aitkin High','306 2nd St NW','Aitkin','56431')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (10625510000,'Linwood-Monroe Arts Lower','1023 Osceola Ave','Saint Paul','55105')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (10625310000,'Battle Creek Middle','2121 Park Dr N','Saint Paul','55119')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (10625210000,'Central High','275 Lexington Pkwy N','Saint Paul','55104')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (10621066000,'Edgewood Middle','5100 Edgewood Dr N','Mounds View','55112')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (10621065000,'Irondale High','2425 Long Lake Rd','New Brighton','55112')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (12909031000,'Eveleth-Gilbert Jr. High','1 Summit St S','Gilbert','55741')
INSERT INTO SCHOOLS (ORGID,SCHNAME,ADDRESS,CITY,ZIP) VALUES (12909030000,'Roosevelt Elem','411 5th Ave S','Virginia','55792')

/******END BUILD SCHEMA *********/
```

##### Query the city and county  tables
The following sections are individual queries for the above schema. Give 'em a whirl!
```SQL
--Get records from the school district table
SELECT * FROM SCHOOL_DISTRICT
```
```SQL
--Get TYPE 1 records from the school district table
SELECT * FROM SCHOOL_DISTRICT WHERE TYPE = '01'
```
```SQL
--Do some manipulations to get formatted IDs
SELECT 
    ORGID
    ,NAME
    ,CONCAT(NUMBER,'-',TYPE) as formattedID
FROM SCHOOL_DISTRICT
```
```SQL
--Do a join to get the district office address
SELECT 
    d.ORGID
    ,d.NAME as districtName
    ,CONCAT(d.NUMBER,'-',d.TYPE) as formattedID
    ,CONCAT(s.ADDRESS,', ',s.CITY,', MN ',s.ZIP) as Address
FROM SCHOOL_DISTRICT d
LEFT JOIN SCHOOLS s ON d.ORGID = s.ORGID
```
```SQL
--Get records from the schools table
SELECT * FROM SCHOOLS
```
```SQL
--Get just the schools, not the offices
SELECT * FROM SCHOOLS
WHERE ALT_NAME IS NULL
```
```SQL
--Sort the schools by zip code
SELECT * FROM SCHOOLS
WHERE ALT_NAME IS NULL
ORDER BY ZIP
```
```SQL
--Do some column manipulations
SELECT
    ORGID as schoolId
    ,SCHNAME as schoolName
    ,CONCAT(ADDRESS,', ',CITY,', MN ',ZIP) as Address
FROM SCHOOLS
```
```SQL
--Create a column for the districtID
SELECT
    ORGID as schoolId
    ,FLOOR(ORGID/1000000)*1000000 as districtID
    ,SCHNAME as schoolName
    ,CONCAT(ADDRESS,', ',CITY,', MN ',ZIP) as Address
FROM SCHOOLS
```
```SQL
--Use that calculation to figure out the name of the district
SELECT
    s.ORGID as schoolId
    ,FLOOR(s.ORGID/1000000)*1000000 as districtID
    ,d.NAME as districtName
    ,s.SCHNAME as schoolName
    ,CONCAT(s.ADDRESS,', ',s.CITY,', MN ',s.ZIP) as Address
FROM SCHOOLS s
LEFT JOIN SCHOOL_DISTRICT d ON d.ORGID = FLOOR(s.ORGID/1000000)*1000000 
```
```SQL
--Get the formatted ID for the school
SELECT
    s.ORGID as schoolId
    ,FLOOR(s.ORGID/1000000)*1000000 as districtID
    ,CONCAT(d.NUMBER,'-',d.TYPE,'-',SUBSTRING(CONVERT(varchar(12),s.ORGID),6,3)) as formattedID --derive from district number and type, and the 3 digits from 6-8 in the school ID
    ,d.NAME as districtName
    ,s.SCHNAME as schoolName
    ,CONCAT(s.ADDRESS,', ',s.CITY,', MN ',s.ZIP) as Address
FROM SCHOOLS s
LEFT JOIN SCHOOL_DISTRICT d ON d.ORGID = FLOOR(s.ORGID/1000000)*1000000
```
```SQL
--But wait we don't want the 000 at the end of a district formatted ID
SELECT
    s.ORGID as schoolId
    ,FLOOR(s.ORGID/1000000)*1000000 as districtID
    ,CASE WHEN SUBSTRING(CONVERT(varchar(12),s.ORGID),6,3) = '000' THEN CONCAT(d.NUMBER,'-',d.TYPE)
        ELSE CONCAT(d.NUMBER,'-',d.TYPE,'-',SUBSTRING(CONVERT(varchar(12),s.ORGID),6,3)) --derive from district number and type, and the 3 digits from 6-8 in the school ID
    END AS formattedID
    ,d.NAME as districtName
    ,s.SCHNAME as schoolName
    ,CONCAT(s.ADDRESS,', ',s.CITY,', MN ',s.ZIP) as Address
FROM SCHOOLS s
LEFT JOIN SCHOOL_DISTRICT d ON d.ORGID = FLOOR(s.ORGID/1000000)*1000000
```