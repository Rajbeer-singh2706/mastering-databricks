-- Databricks notebook source
`CREATE TABLE employees
  (id INT, name STRING, salary DOUBLE);`
  -- USING DELTA 

-- IN data section , default database , there we can find employees tables;hive_metastore.default.employees
-- COMMAND ----------

INSERT INTO employees
VALUES 
  (1, "Adam", 3500.0),
  (2, "Sarah", 4020.5),
  (3, "John", 2999.3),
  (4, "Thomas", 4000.3),
  (5, "Anna", 2500.0),
  (6, "Kim", 6200.3)

-- COMMAND ----------
SELECT * FROM employees

-- COMMAND ----------
DESCRIBE DETAIL employees
--location, numFiles

-- COMMAND ----------

-- MAGIC 
%fs ls 'dbfs:/user/hive/warehouse/employees'
-- 4 data files 
-- _delta_log/
-- Cluster has 4 cores

-- COMMAND ----------
UPDATE employees SET salary = salary + 100 WHERE name LIKE "A%"

-- COMMAND ----------
SELECT * FROM employees

-- COMMAND ----------
%fs ls 'dbfs:/user/hive/warehouse/employees'

-- COMMAND ----------
DESCRIBE DETAIL employees
-- no of files 4 only 

-- COMMAND ----------
SELECT * FROM employees

-- COMMAND ----------
DESCRIBE HISTORY employees

-- COMMAND ----------

-- MAGIC 
%fs ls 'dbfs:/user/hive/warehouse/employees/_delta_log'

-- COMMAND -- MAGIC 
%fs head 'dbfs:/user/hive/warehouse/employees/_delta_log/00000000000000000002.json'

{"commitInfo":{"timestamp":1698241936064,"userId":"8793005805939155","userName":"testsparkaws@gmail.com","operation":"UPDATE","operationParameters":{"predicate":"[\"StartsWith(name#1839, A)\"]"},"notebook":{"notebookId":"1362777926003503"},"clusterId":"1025-124022-h2fh2j84","readVersion":1,"isolationLevel":"WriteSerializable","isBlindAppend":false,"operationMetrics":{"numRemovedFiles":"1","numRemovedBytes":"1155","numCopiedRows":"4","numDeletionVectorsAdded":"0","numDeletionVectorsRemoved":"0","numAddedChangeFiles":"0","executionTimeMs":"3411","scanTimeMs":"1866","numAddedFiles":"1","numUpdatedRows":"2","numAddedBytes":"1155","rewriteTimeMs":"1508"},"engineInfo":"Databricks-Runtime/12.2.x-scala2.12","txnId":"24cdf255-c884-4f6d-8807-c800a4df835c"}}
{"remove":{"path":"part-00000-ce262b4b-61ea-4c37-b836-52a0f2827b43-c000.snappy.parquet","deletionTimestamp":1698241936036,"dataChange":true,"extendedFileMetadata":true,"partitionValues":{},"size":1155,"tags":{"INSERTION_TIME":"1698241486000000","MIN_INSERTION_TIME":"1698241486000000","MAX_INSERTION_TIME":"1698241486000000","OPTIMIZE_TARGET_SIZE":"268435456"}}}
{"add":{"path":"part-00000-10f3422b-3fcb-41f3-90b9-cb8cb3cec760-c000.snappy.parquet","partitionValues":{},"size":1155,"modificationTime":1698241936000,"dataChange":true,"stats":"{\"numRecords\":6,\"minValues\":{\"id\":1,\"name\":\"Adam\",\"salary\":2600.0},\"maxValues\":{\"id\":6,\"name\":\"Thomas\",\"salary\":6200.3},\"nullCount\":{\"id\":0,\"name\":0,\"salary\":0}}","tags":{"MAX_INSERTION_TIME":"1698241486000000","INSERTION_TIME":"1698241486000000","MIN_INSERTION_TIME":"1698241486000000","OPTIMIZE_TARGET_SIZE":"268435456"}}}
