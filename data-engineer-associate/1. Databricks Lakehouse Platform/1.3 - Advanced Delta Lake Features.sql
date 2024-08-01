-- Databricks notebook source
DESCRIBE HISTORY employees
-- version (2, 1, 0)

-- COMMAND ----------
SELECT * 
FROM employees VERSION AS OF 1

-- COMMAND ----------
SELECT * FROM employees@v1

-- COMMAND ----------
DELETE FROM employees
-- -1 : all data removed

-- COMMAND ----------
SELECT * FROM employees

-- COMMAND ----------
RESTORE TABLE employees TO VERSION AS OF 2 

-- COMMAND ----------

SELECT * FROM employees


-- COMMAND ----------
DESCRIBE HISTORY employees
-- Version , operation
-- 4 ,restore
-- 3, delete
-- 2, update
-- 1, write
-- 0, create tables  


-- COMMAND ----------
DESCRIBE DETAIL employees
--numFiles : 4

-- COMMAND ----------
OPTIMIZE employees
ZORDER BY id

-- numFilesAdded: 1
-- numFileRemoved: 4

-- COMMAND ----------
DESCRIBE DETAIL employees
-- numFile: 1

-- COMMAND ----------
DESCRIBE HISTORY employees
-- Version , operation
-- 5, OPTIMIZE

-- COMMAND ---- MAGIC 
%fs ls 'dbfs:/user/hive/warehouse/employees'
-- 7 data files 

-- COMMAND ---------- removed unsued files 
VACUUM employees


-- COMMAND ---------- MAGIC 
%fs ls 'dbfs:/user/hive/warehouse/employees'
-- nothing happendm retenion period is 7 days so it will wait for 7 days

-- COMMAND ----------
VACUUM employees RETAIN 0 HOURS

-- COMMAND ---------- this is for testing only , dont do in production
SET spark.databricks.delta.retentionDurationCheck.enabled = false;

-- COMMAND ----------
VACUUM employees RETAIN 0 HOURS

-- COMMAND ---
%fs ls 'dbfs:/user/hive/warehouse/employees'

-- COMMAND ----------
SELECT * FROM employees@v1
-- file not found exception

-- COMMAND ----------
DROP TABLE employees

-- COMMAND ----------
SELECT * FROM employees

-- COMMAND ---- MAGIC 
%fs ls 'dbfs:/user/hive/warehouse/employees'