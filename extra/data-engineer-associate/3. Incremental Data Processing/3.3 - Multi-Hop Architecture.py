# Databricks notebook source
# MAGIC %md-sandbox
# MAGIC 
# MAGIC <div  style="text-align: center; line-height: 0; padding-top: 9px;">
# MAGIC   <img src="https://dalhussein.blob.core.windows.net/course-resources/bookstore_schema.png" alt="Databricks Learning" style="width: 600">
# MAGIC </div>

# COMMAND ----------
%run ../Includes/Copy-Datasets

# COMMAND ----------
files = dbutils.fs.ls(f"{dataset_bookstore}/orders-raw")
display(files)

# COMMAND ----------
(spark.readStream
    .format("cloudFiles")
    .option("cloudFiles.format", "parquet")
    .option("cloudFiles.schemaLocation", "dbfs:/mnt/demo/checkpoints/orders_raw")
    .load(f"{dataset_bookstore}/orders-raw")
    .createOrReplaceTempView("orders_raw_temp"))

# COMMAND ----------
%sql
CREATE OR REPLACE TEMPORARY VIEW orders_tmp AS (
   SELECT *, current_timestamp() arrival_time, input_file_name() source_file
   FROM orders_raw_temp
 )

# COMMAND ----------
SELECT * FROM orders_tmp

# COMMAND ----------
(spark.table("orders_tmp")
      .writeStream
      .format("delta")
      .option("checkpointLocation", "dbfs:/mnt/demo/checkpoints/orders_bronze")
      .outputMode("append")
      .table("orders_bronze"))

# COMMAND ----------
SELECT count(*) FROM orders_bronze

# COMMAND ----------
load_new_data()

# COMMAND ----------
(spark.read
      .format("json")
      .load(f"{dataset_bookstore}/customers-json")
      .createOrReplaceTempView("customers_lookup"))

# COMMAND ----------
SELECT * FROM customers_lookup

# COMMAND ---------- streaming temporary view on bronze table
(spark.readStream
  .table("orders_bronze")
  .createOrReplaceTempView("orders_bronze_tmp"))

# COMMAND ----------
CREATE OR REPLACE TEMPORARY VIEW orders_enriched_tmp AS (
  SELECT order_id, quantity, o.customer_id, c.profile:first_name as f_name, c.profile:last_name as l_name,
         cast(from_unixtime(order_timestamp, 'yyyy-MM-dd HH:mm:ss') AS timestamp) order_timestamp, books
  FROM orders_bronze_tmp o
  INNER JOIN customers_lookup c
  ON o.customer_id = c.customer_id
  WHERE quantity > 0)

#COMMAND ----------
(spark.table("orders_enriched_tmp")
      .writeStream
      .format("delta")
      .option("checkpointLocation", "dbfs:/mnt/demo/checkpoints/orders_silver")
      .outputMode("append")
      .table("orders_silver"))

# COMMAND ----------
#SELECT * FROM orders_silver

# COMMAND ----------
SELECT COUNT(*) FROM orders_silver

# COMMAND ----------
load_new_data()

# COMMAND ---------- Streaming Temporary view on Silver table
(spark.readStream
  .table("orders_silver")
  .createOrReplaceTempView("orders_silver_tmp"))

# COMMAND ----------
'''
CREATE OR REPLACE TEMP VIEW daily_customer_books_tmp AS (
   SELECT customer_id, f_name, l_name, date_trunc("DD", order_timestamp) order_date, sum(quantity) books_counts
   FROM orders_silver_tmp
   GROUP BY customer_id, f_name, l_name, date_trunc("DD", order_timestamp)
   )
'''
#COMMAND ----------
(spark.table("daily_customer_books_tmp")
      .writeStream
      .format("delta")
      .outputMode("complete")
      .option("checkpointLocation", "dbfs:/mnt/demo/checkpoints/daily_customer_books")
      .trigger(availableNow=True)
      .table("daily_customer_books"))

# COMMAND ---------- GOLD TABLE
SELECT * FROM daily_customer_books

# COMMAND ----------
load_new_data(all=True)

# COMMAND ----------
for s in spark.streams.active:
    print("Stopping stream: " + s.id)
    s.stop()
    s.awaitTermination()

# COMMAND ----------