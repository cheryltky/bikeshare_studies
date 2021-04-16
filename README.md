
##### Insights into US Bikeshare Companies

###### Aims:

-   Provide data-driven insights into overall trends in customer
    subscription models, seasonal and location demand.

-   Provide bikeshare companies with the ability to make data-driven
    decisions for potential resource allocations, maximise profits and
    improve customer quality care.

**Datasets extracted via PostGresQL**

-   [Bluebikes System Dataset](https://s3.amazonaws.com/hubway-data/index.html)
-   [DivvyBikes Dataset](https://divvy-tripdata.s3.amazonaws.com/index.html)

**Visualisations to analysis questions** (http://htmlpreview.github.io/?https://raw.githubusercontent.com/cheryltky/bikeshare_studies/main/plots.html)


**Analysis Questions with SQL queries:**

###### 1.*How many trips were there in each month of each year?*

``` sql
with bluebikes_Join as (    select * from bluebikes_2017
                    UNION ALL
                    select * from bluebikes_2018
                    UNION ALL
                    select * from bluebikes_2019),
divvy_Join as (     select * from divvybikes_2017
                    UNION ALL
                    select * from divvybikes_2018
                    UNION ALL
                    select * from divvybikes_2019),
bluebikes_table as (select  distinct count(*) as trips_bluebike, date_part('month', start_time) as month,date_part('year', start_time) as year from bluebikes_Join
    group by date_part('month', start_time),date_part('year', start_time)),
    divvy_table as (select distinct count(*) as trips_divvy, date_part('month', start_time) as month,date_part('year', start_time) as year from divvy_Join
group by date_part('month', start_time),date_part('year', start_time))
    select * from bluebikes_table 
    left join divvy_table using(month,year)
    order by year,month asc
```

------------------------------------------------------------------------

###### 2.Which stations are showing the greatest growth rates?

``` sql
with bluebikes_Join as (    select * from bluebikes_2017
                    UNION ALL
                    select * from bluebikes_2018
                    UNION ALL
                    select * from bluebikes_2019),
divvy_Join as (     select * from divvybikes_2017
                    UNION ALL
                    select * from divvybikes_2018
                    UNION ALL
                    select * from divvybikes_2019),
bluebikes_table as (select  distinct count(*) as trips_bluebike, date_part('month', start_time) as month,date_part('year', start_time) as year from bluebikes_Join
    group by date_part('month', start_time),date_part('year', start_time)),
    divvy_table as (select distinct count(*) as trips_divvy, date_part('month', start_time) as month,date_part('year', start_time) as year from divvy_Join
group by date_part('month', start_time),date_part('year', start_time))
    select * from bluebikes_table 
    left join divvy_table using(month,year)
    order by year,month asc
    select * from bluebikes_table
    order by year,month asc
```

``` sql
Divvy Bikes Month on Month Data breakdown of subscribers (absolute figures)

with divvy_Join as (    select * from divvybikes_2017
                    UNION
                    select * from divvybikes_2018
                    UNION
                    select * from divvybikes_2019),
divvy_table as (select distinct count(user_type) as total_users, date_part('year', start_time) as year,date_part('month', start_time) as month from divvy_Join
    where user_type = 'Subscriber'
    group by date_part('month', start_time),date_part('year', start_time))
    select * from divvy_table
    order by year,month asc
```

``` sql
Divvy Bikes Data count (used for expression as proportion of total subscriber share)

select distinct count(user_type)
from divvybikes_2019
UNION ALL   
select distinct count(user_type)
from divvybikes_2018    
UNION ALL
select distinct count(user_type)
from divvybikes_2017
Blue Bikes Data count (used for expression as proportion of total subscriber share)

select distinct count(user_type)
from bluebikes_2019
UNION ALL   
select distinct count(user_type)
from bluebikes_2018 
UNION ALL
select distinct count(user_type)
from bluebikes_2017
```

------------------------------------------------------------------------

###### 3. Is there a difference in growth between holiday activity and commuting activity?

``` sql
Divvybikes Data

with divvy_Join as (    select * from divvybikes_2017
                    UNION
                    select * from divvybikes_2018
                    UNION
                    select * from divvybikes_2019),
divvy_table as (select distinct count(user_type) as total_users, date_part('year', start_time) as year,date_part('month', start_time) as month from divvy_Join
    where user_type = 'Subscriber'
    group by date_part('month', start_time),date_part('year', start_time))
    select * from divvy_table
    order by year,month asc
```

``` sql
Bluebikes data

WITH bluebikes_Join as 
(SELECT * FROM bluebikes_2017
UNION ALL
SELECT * FROM bluebikes_2018
UNION ALL
SELECT * FROM bluebikes_2019),
bluebikes_table as 
(SELECT DISTINCT
date_part('year', start_time) as year,
CASE
WHEN date_part('month',start_time) BETWEEN 03 AND 05 THEN 'Spring'
WHEN date_part('month',start_time) BETWEEN 06 AND 08 THEN 'Summer'
WHEN date_part('month',start_time) BETWEEN 09 AND 11 THEN 'Autumn'
ELSE 'Winter'
END AS season,
date_part('month', start_time) as month,
date_part('day',start_time) as day,
rtrim(to_char(start_time, 'day')) AS day_name,
CASE
 WHEN rtrim(to_char(start_time, 'day')) = 'sunday' THEN TRUE
 WHEN rtrim(to_char(start_time, 'day')) = 'saturday' THEN TRUE
 ELSE FALSE 
END AS Weekend,
count(user_type) as total_users
FROM bluebikes_Join
/* WHERE user_type = 'Subscriber'  */
GROUP BY year,season,month,day,day_name,weekend)
SELECT * 
FROM bluebikes_table
ORDER BY year,month,day ASC
```

------------------------------------------------------------------------

###### 4. What was the longest journey? What do we know about it?

``` sql
WITH
L1_bbikes_2019 AS 
(SELECT 
b.bike_id,
b.start_time,
b.start_station_id,
b.end_station_id,
s.latitude as ss_latitude,
s.longtitude as ss_longitude
FROM bluebikes_2019 b
JOIN bluebikes_stations s ON b.start_station_id = s.id
WHERE b.start_station_id != b.end_station_id AND (date_part('month',start_time) BETWEEN 01 AND 12))
SELECT 
b.bike_id,
b.start_time,
b.start_station_id,
b.end_station_id,
b.ss_latitude,          /* Start stations info */
b.ss_longitude,
e.latitude as es_latitude,    /* End stations info */
e.longtitude as es_longitude,
calculate_distance(b.ss_latitude, b.ss_longitude, 
                          e.latitude, e.longtitude, 
                          'K')
FROM L1_bbikes_2019 b
JOIN bluebikes_stations e ON b.end_station_id = e.id
ORDER BY calculate_distance DESC
LIMIT 10
```

##### *longest journey*

``` sql
select *
FROM bluebikes_stations
where id = 217
--or where id =82
```

``` sql
Divvy Bikes 
WITH
L1_divvybikes_2019 AS
(SELECT
b.bikeid,
b.start_time,
b.start_station_id,
b.end_station_id,
s.latitude as ss_latitude,
s.longitude as ss_longitude
FROM divvybikes_2019 b
JOIN divvy_stations s ON b.start_station_id = s.id
WHERE b.start_station_id != b.end_station_id AND (date_part('month',start_time) BETWEEN 01 AND 12))
SELECT
b.bikeid,
b.start_time,
b.start_station_id,
b.end_station_id,
b.ss_latitude,          /* Start stations info */
b.ss_longitude,
e.latitude as es_latitude,    /* End stations info */
e.longitude as es_longitude,
calculate_distance(b.ss_latitude, b.ss_longitude,
                          e.latitude, e.longitude,
                          'K')
FROM L1_divvybikes_2019 b
JOIN divvy_stations e ON b.end_station_id = e.id
ORDER BY calculate_distance DESC
LIMIT 10



WITH
L1_divvybikes_2019 AS
(SELECT
b.bikeid,
b.start_time,
b.start_station_id,
b.end_station_id,
s.latitude as ss_latitude,
s.longitude as ss_longitude
FROM divvybikes_2019 b
JOIN divvy_stations s ON b.start_station_id = s.id
WHERE b.start_station_id != b.end_station_id AND (date_part('month',start_time) BETWEEN 01 AND 12))
SELECT
b.bikeid,
b.start_time,
b.start_station_id,
b.end_station_id,
b.ss_latitude,          /* Start stations info */
b.ss_longitude,
e.latitude as es_latitude,    /* End stations info */
e.longitude as es_longitude,
calculate_distance(b.ss_latitude, b.ss_longitude,
                          e.latitude, e.longitude,
                          'K')
FROM L1_divvybikes_2019 b
JOIN divvy_stations e ON b.end_station_id = e.id
ORDER BY calculate_distance DESC
LIMIT 10
```

------------------------------------------------------------------------

###### 5. *How often do bikes need to be relocated?*

``` sql
2019 Bluebike

WITH
bike_cte AS                  /* Grab the rides in order */
(SELECT Distinct bike_id, start_time, start_station_id as start, end_station_id as stop
FROM bluebikes_2019
ORDER BY bike_id,start_time),
delay_cte AS         /* Grab the start position and the previous end position */
(SELECT bike_id, start_time, start, LAG(stop, 1) OVER( Partition BY 1) as previous_stop
FROM bike_cte),
moved_bike AS     /* Was the bike moved or not */
(SELECT bike_id, start_time, start, previous_stop, start!=previous_stop AS Moved
FROM delay_cte),
total_rides AS      /* Count all the rides */
(SELECT date_part('month',start_time) AS month, count(*) AS number_of_rides
FROM bluebikes_2019
GROUP BY month
ORDER BY month),
total_moves AS     /* Count all the moves */
(SELECT date_part('month',start_time) AS month, count(CASE WHEN moved THEN 1 END) AS number_of_moves
FROM moved_bike
GROUP BY month
ORDER BY month)
-- Grab the monthly moves and total rides
SELECT 
m.month,
number_of_moves,
number_of_rides
FROM total_rides
JOIN total_moves m USING(month)
'''
'''sql
2018 Bluebike
WITH
bike_cte AS                  /* Grab the rides in order */
(SELECT Distinct bike_id, start_time, start_station_id as start, end_station_id as stop
FROM bluebikes_2018
ORDER BY bike_id,start_time),
delay_cte AS         /* Grab the start position and the previous end position */
(SELECT bike_id, start_time, start, LAG(stop, 1) OVER( Partition BY 1) as previous_stop
FROM bike_cte),
moved_bike AS     /* Was the bike moved or not */
(SELECT bike_id, start_time, start, previous_stop, start!=previous_stop AS Moved
FROM delay_cte),
total_rides AS      /* Count all the rides */
(SELECT date_part('month',start_time) AS month, count(*) AS number_of_rides
FROM bluebikes_2018
GROUP BY month
ORDER BY month),
total_moves AS     /* Count all the moves */
(SELECT date_part('month',start_time) AS month, count(CASE WHEN moved THEN 1 END) AS number_of_moves
FROM moved_bike
GROUP BY month
ORDER BY month)
-- Grab the monthly moves and total rides
SELECT 
m.month,
number_of_moves,
number_of_rides
FROM total_rides
JOIN total_moves m USING(month)
```

``` sql
2017 Bluebike


WITH
bike_cte AS                  /* Grab the rides in order */
(SELECT Distinct bike_id, start_time, start_station_id as start, end_station_id as stop
FROM bluebikes_2017
ORDER BY bike_id,start_time),
delay_cte AS         /* Grab the start position and the previous end position */
(SELECT bike_id, start_time, start, LAG(stop, 1) OVER( Partition BY 1) as previous_stop
FROM bike_cte),
moved_bike AS     /* Was the bike moved or not */
(SELECT bike_id, start_time, start, previous_stop, start!=previous_stop AS Moved
FROM delay_cte),
total_rides AS      /* Count all the rides */
(SELECT date_part('month',start_time) AS month, count(*) AS number_of_rides
FROM bluebikes_2017
GROUP BY month
ORDER BY month),
total_moves AS     /* Count all the moves */
(SELECT date_part('month',start_time) AS month, count(CASE WHEN moved THEN 1 END) AS number_of_moves
FROM moved_bike
GROUP BY month
ORDER BY month)
-- Grab the monthly moves and total rides
SELECT 
m.month,
number_of_moves,
number_of_rides
FROM total_rides
JOIN total_moves m USING(month)
```

``` sql
Divvybikes 2019

WITH
bike_cte AS                  /* Grab the rides in order */
(SELECT Distinct bikeid, start_time, start_station_id as start, end_station_id as stop
FROM divvybikes_2019
ORDER BY bikeid,start_time),
delay_cte AS         /* Grab the start position and the previous end position */
(SELECT bikeid, start_time, start, LAG(stop, 1) OVER( Partition BY 1) as previous_stop
FROM bike_cte),
moved_bike AS     /* Was the bike moved or not */
(SELECT bikeid, start_time, start, previous_stop, start!=previous_stop AS Moved
FROM delay_cte),
total_rides AS      /* Count all the rides */
(SELECT date_part('month',start_time) AS month, count(*) AS number_of_rides
FROM divvybikes_2019
GROUP BY month
ORDER BY month),
total_moves AS     /* Count all the moves */
(SELECT date_part('month',start_time) AS month, count(CASE WHEN moved THEN 1 END) AS number_of_moves
FROM moved_bike
GROUP BY month
ORDER BY month)
--monthly moves and total rides
SELECT 
m.month,
number_of_moves,
number_of_rides
FROM total_rides
JOIN total_moves m USING(month)
```

``` sql
Divvybikes 2018

WITH
bike_cte AS                  /* Grab the rides in order */
(SELECT Distinct bikeid, start_time, start_station_id as start, end_station_id as stop
FROM divvybikes_2018
ORDER BY bikeid,start_time),
delay_cte AS         /* Grab the start position and the previous end position */
(SELECT bikeid, start_time, start, LAG(stop, 1) OVER( Partition BY 1) as previous_stop
FROM bike_cte),
moved_bike AS     /* Was the bike moved or not */
(SELECT bikeid, start_time, start, previous_stop, start!=previous_stop AS Moved
FROM delay_cte),
total_rides AS      /* Count all the rides */
(SELECT date_part('month',start_time) AS month, count(*) AS number_of_rides
FROM divvybikes_2018
GROUP BY month
ORDER BY month),
total_moves AS     /* Count all the moves */
(SELECT date_part('month',start_time) AS month, count(CASE WHEN moved THEN 1 END) AS number_of_moves
FROM moved_bike
GROUP BY month
ORDER BY month)
-- Grab the monthly moves and total rides
SELECT 
m.month,
number_of_moves,
number_of_rides
FROM total_rides
JOIN total_moves m USING(month)
```

``` sql
Divvybikes 2017

WITH
bike_cte AS                  /* Grab the rides in order */
(SELECT Distinct bikeid, start_time, start_station_id as start, end_station_id as stop
FROM divvybikes_2017
ORDER BY bikeid,start_time),
delay_cte AS         /* Grab the start position and the previous end position */
(SELECT bikeid, start_time, start, LAG(stop, 1) OVER( Partition BY 1) as previous_stop
FROM bike_cte),
moved_bike AS     /* Was the bike moved or not */
(SELECT bikeid, start_time, start, previous_stop, start!=previous_stop AS Moved
FROM delay_cte),
total_rides AS      /* Count all the rides */
(SELECT date_part('month',start_time) AS month, count(*) AS number_of_rides
FROM divvybikes_2017
GROUP BY month
ORDER BY month),
total_moves AS     /* Count all the moves */
(SELECT date_part('month',start_time) AS month, count(CASE WHEN moved THEN 1 END) AS number_of_moves
FROM moved_bike
GROUP BY month
ORDER BY month)
-- Grab the monthly moves and total rides
SELECT 
m.month,
number_of_moves,
number_of_rides
FROM total_rides
JOIN total_moves m USING(month)
```

------------------------------------------------------------------------

###### 6. *How far is a typical journey?*

``` sql
Bluebikes 2019

WITH
L1_bbikes_2019 AS 
(SELECT 
b.bike_id,
b.start_time,
b.start_station_id,
b.end_station_id,
s.latitude as ss_latitude,
s.longtitude as ss_longitude
FROM bluebikes_2019 b
JOIN bluebikes_stations s ON b.start_station_id = s.id
WHERE b.start_station_id != b.end_station_id)
SELECT 
AVG(calculate_distance(b.ss_latitude, b.ss_longitude, 
                          e.latitude, e.longtitude, 
                          'K')),
     date_part('month',start_time) As month
FROM L1_bbikes_2019 b
JOIN bluebikes_stations e ON b.end_station_id = e.id
Group by month
Order by month

Divvy Bikes 2019
WITH
L1_divvybikes_2019 AS 
(SELECT 
b.bikeid,
b.start_time,
b.start_station_id,
b.end_station_id,
s.latitude as ss_latitude,
s.longitude as ss_longitude
FROM divvybikes_2019 b
JOIN divvy_stations s ON b.start_station_id = s.id
WHERE b.start_station_id != b.end_station_id)
SELECT 
AVG(calculate_distance(b.ss_latitude, b.ss_longitude, 
                          e.latitude, e.longitude, 
                          'K')),
     date_part('month',start_time) As month
FROM L1_divvybikes_2019 b
JOIN divvy_stations e ON b.end_station_id = e.id
Group by month
Order by month
```

------------------------------------------------------------------------

###### 7. *How effective are subscription systems?*

``` sql
with
----blubikes data for 2017 and  2018
bluebikes_data_combined as (
select bike_id,start_time,end_time,start_station_id,end_station_id,user_type
from bluebikes_2017
union
select bike_id,start_time,end_time,start_station_id,end_station_id,user_type
from bluebikes_2018 ),


----baywheels data for 2017 and 2018 
baywheels_data_combined as (
select bike_id,start_time,end_time,start_station_id,end_station_id,user_type
from baywheels_2017
union
select bike_id,start_time,end_time,start_station_id,end_station_id,user_type
from baywheels_2018 ),


--- bike data for bluebikes and baywheels combined

total_bike_data as (select bike_id,start_time,end_time,start_station_id,end_station_id,user_type,  'bluebikes' as company_name
from bluebikes_data_combined
union
select bike_id,start_time,end_time,start_station_id,end_station_id,user_type,  'baywheels' as company_name
from baywheels_data_combined)


------ counting no of trips taken by customers and subscribes in two diff companies.
                select count(*) as no_of_trips,user_type,  company_name
                from total_bike_data
                group by user_type , company_name
                order by no_of_trips
```
