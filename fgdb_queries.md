# File-based Geodatabase (FGDB) Queries
Believe it or not, you can use SQL when querying file-based geodatabases (FGDB) as well. Especially when querying from a single layer, knowledge of SQL can help you more quickly and efficiently write regular SELECT queries as well as definition queries. [This Esri help article](https://desktop.arcgis.com/en/arcmap/latest/map/working-with-layers/sql-reference-for-query-expressions-used-in-arcgis.htm), while written for ArcGIS Desktop, is still valid for much of ArcGIS Pro, and can be useful for understanding how to use SQL with various formats.

## Subqueries
One of the most useful tricks in SQL is subqueries - a nested query within another, frequently leveraged to query records from one table (aka layer) based on what is available in another. As the article above notes:
> Subquery support in file geodatabases is limited to the following:
>    IN predicate. For example:
>    "COUNTRY_NAME" NOT IN (SELECT "COUNTRY_NAME" FROM indep_countries)
>    Scalar subqueries with comparison operators. A scalar subquery returns a single value. For example:
>    "GDP2006" > (SELECT MAX("GDP2005") FROM countries)
>        For file geodatabases, the set functions AVG, COUNT, MIN, MAX, and SUM can only be used within scalar subqueries.
>    EXISTS predicate. For example:
>    EXISTS (SELECT * FROM indep_countries WHERE "COUNTRY_NAME" = 'Mexico')

The "IN" predicate is very useful for testing to see if records from one layer exist in another. When testing this function in ArcGIS Pro, it only worked when using feature classes housed within the same file-based geodatabase (.gdb "folder"). The concept is demonstrated in definition query of the "School Program Locations" layer of the "fgdb_queries.aprx" in this repository.

``` SQL
ORGID IN (SELECT SDORGID FROM school_district_boundaries)
```