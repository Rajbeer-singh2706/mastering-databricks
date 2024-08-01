# Data Enginneering 
# Data Scientists 
# SQL Personna 
-- SQL Editor 
-- SQL Warehouse 
-- Query History
-- Queries 
-- Dashboards 

# SQL Warehouse
-- Create SQL Warehouse 
-- Name; DEMO Warehouse 
-- Custer_SIze : 2x0saml
-- Create 


# NYC Taxi Trip Analysis -> Import 
# add Pie Chart to Dasboard 


### Create new SQL Query 
# Reschdule > Refresh Every 1 Week : 1 AM 
select 
 pickup_zip,
 sum(fare_amount) as total_fare

FROM nyctaxi.trips 
GROUP BY pickup_zip;

# SAVE > Name > Add to Dashboard  


### Create ALERT 
Name: Total Fares alert 
Tigerr When total_fare > 10000

Refresh: NEver 
Create Alert 
# Refresh 

# ADd destination : Alert Destination : Emal/Slack/Teams/GCHAR > Create