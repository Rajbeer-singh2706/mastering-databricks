### Create new Spark Notebook and test it 

-- Databricks notebook source
SHOW TABLES; -- temp view is not here in session2  , but exists in session1

-- COMMAND ----------
SHOW TABLES IN global_temp;

-- COMMAND ----------
SELECT * FROM global_temp.global_temp_view_latest_phones;

-- COMMAND ----------
DROP TABLE smartphones;

DROP VIEW view_apple_phones;
DROP VIEW global_temp.global_temp_view_latest_phones;