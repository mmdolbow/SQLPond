/******BUILD SCHEMAS*********/

/* ***County and Citi */
--create the county table
CREATE TABLE COUNTY(
	COUNTYFIPS smallint NOT NULL,
	CTY_NAME varchar(20) NULL
);

--create the CTU table
CREATE TABLE CTU(
    GNISTXT varchar(8) NOT NULL,
	FEATNAME varchar(40) NULL,
    CTUTYPE varchar(24) NULL,
	CTYNUM varchar(3) NULL
);

--Create the school district table
CREATE TABLE SCHOOL_DISTRICT(
	ORGID numeric(12, 0) NULL,
	NAME varchar(50) NULL,
    TYPE varchar(2) NULL,
    NUMBER varchar(4) NULL
);

--Create the schools table
CREATE TABLE SCHOOLS(
	ORGID numeric(12, 0) NULL,
	SCHNAME varchar(50) NULL,
	ADDRESS varchar(40) NULL,
	CITY varchar(35) NULL,
	ZIP varchar(10) NULL,
	ALT_NAME varchar(50) NULL
);