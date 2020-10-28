/*Build and query a database of some school districts and schools in Minnesota
This file is the space where we build and test this concept with SQL hints in an IDE. When we're finished,
we dump the SQL into the readme for nicer formatting.
 */

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

/******INDIVIDUAL QUERIES *********/
--Get records from the school district table
SELECT * FROM SCHOOL_DISTRICT

--Get TYPE 1 records from the school district table
SELECT * FROM SCHOOL_DISTRICT WHERE TYPE = '01'

--Do some manipulations to get formatted IDs
SELECT 
    ORGID
    ,NAME
    ,CONCAT(NUMBER,'-',TYPE) as formattedID
FROM SCHOOL_DISTRICT

--Do a join to get the district office address
SELECT 
    d.ORGID
    ,d.NAME as districtName
    ,CONCAT(d.NUMBER,'-',d.TYPE) as formattedID
    ,CONCAT(s.ADDRESS,', ',s.CITY,', MN ',s.ZIP) as Address
FROM SCHOOL_DISTRICT d
LEFT JOIN SCHOOLS s ON d.ORGID = s.ORGID

--Get records from the schools table
SELECT * FROM SCHOOLS

--Get just the schools, not the offices
SELECT * FROM SCHOOLS
WHERE ALT_NAME IS NULL

--Sort the schools by zip code
SELECT * FROM SCHOOLS
WHERE ALT_NAME IS NULL
ORDER BY ZIP

--Do some column manipulations
SELECT
    ORGID as schoolId
    ,SCHNAME as schoolName
    ,CONCAT(ADDRESS,', ',CITY,', MN ',ZIP) as Address
FROM SCHOOLS

--Create a column for the districtID
SELECT
    ORGID as schoolId
    ,FLOOR(ORGID/1000000)*1000000 as districtID
    ,SCHNAME as schoolName
    ,CONCAT(ADDRESS,', ',CITY,', MN ',ZIP) as Address
FROM SCHOOLS

--Use that calculation to figure out the name of the district
SELECT
    s.ORGID as schoolId
    ,FLOOR(s.ORGID/1000000)*1000000 as districtID
    ,d.NAME as districtName
    ,s.SCHNAME as schoolName
    ,CONCAT(s.ADDRESS,', ',s.CITY,', MN ',s.ZIP) as Address
FROM SCHOOLS s
LEFT JOIN SCHOOL_DISTRICT d ON d.ORGID = FLOOR(s.ORGID/1000000)*1000000 

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
