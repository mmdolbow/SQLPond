/*Build and query a database of some common cities and counties in Minnesota */

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
	CTYNUM smallint NULL
)

--Insert values into COUNTY table (one at a time at W3schools)
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27003,"Anoka");
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27053,"Hennepin");
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27145,"Stearns");
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27123,"Ramsey");
INSERT INTO COUNTY (COUNTYFIPS,CTY_NAME) VALUES (27093,"Meeker");

--Insert values into the CITY table (one at a time at W3schools)
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02396471','Saint Anthony','City','053');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02396471','Saint Anthony','City','123');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02396472','Saint Anthony','City','145');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02396472','Saint Anthony','City','145');
INSERT INTO CTU (GNISTXT,FEATNAME,CTUTYPE,CTYNUM) VALUES ('02396472','Saint Anthony','City','145');

--Query the COUNTY table with some basic manipulations
SELECT 
COUNTYFIPS AS 'CODE'
,CTY_NAME AS 'NAME'
FROM [COUNTY]

--Query the COUNTY table and mod the name column (using || for SQL Lite concatenation)
SELECT 
COUNTYFIPS AS 'CODE'
,CTY_NAME || ' County' AS 'NAME' --uses SQL Lite concatenation method
FROM [COUNTY]

--Join the two tables to get better looking columns etc
SELECT * FROM [CTU]
LEFT JOIN [COUNTY] ON [CTU].[CTYNUM]+27000 = [COUNTY].[COUNTYFIPS]
