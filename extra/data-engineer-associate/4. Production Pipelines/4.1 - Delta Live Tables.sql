-- Databricks notebook source
-- MAGIC %md
-- MAGIC 
-- MAGIC 
-- MAGIC # Delta Live Tables

-- COMMAND ----------

-- MAGIC %md-sandbox
-- MAGIC 
-- MAGIC <div  style="text-align: center; line-height: 0; padding-top: 9px;">
-- MAGIC   <img src="https://dalhussein.blob.core.windows.net/course-resources/bookstore_schema.png" alt="Databricks Learning" style="width: 600">
-- MAGIC </div>

-- COMMAND ----------
#### DLT(Delta Live tables)
------ RAW----------------  SILVER -------------------- GOLD 
    # Customers       ----   
                      ----- orderes_cleaned ------ cn_daily_customer      
    # orders_raw      -----

%md
## Bronze Layer Tables

-- COMMAND ----------

-- MAGIC %md
#### orders_raw

-- COMMAND ---------- STREAMING LIVE 
CREATE OR REFRESH STREAMING LIVE TABLE orders_raw
COMMENT "The raw books orders, ingested from orders-raw"
AS SELECT * FROM cloud_files("${datasets_path}/orders-json-raw", "json",
                             map("cloudFiles.inferColumnTypes", "true"))

CREATE OR REFRESH STREAMING LIVE TABLE orders_raw
COMMENT "The raw books orders, ingested from orders-raw"
AS SELECT * FROM cloud_files("${datasets_path}/orders-raw", "parquet",
                             map("shema", "order_id STRING, order_timestamp LONG, customer_id STRING, quantity LONG"))

-- COMMAND ----------
%md
#### customers

-- COMMAND ---------- LIVE 
CREATE OR REFRESH LIVE TABLE customers
COMMENT "The customers lookup table, ingested from customers-json"
AS SELECT * FROM json.`${datasets_path}/customers-json`

-- COMMAND ----------
%md
## Silver Layer Tables
#### orders_cleaned

-- COMMAND ----------STREAMING LIVE 
CREATE OR REFRESH STREAMING LIVE TABLE orders_cleaned (
  CONSTRAINT valid_order_number EXPECT (order_id IS NOT NULL) ON VIOLATION DROP ROW
)
COMMENT "The cleaned books orders with valid order_id"
AS
  SELECT 
      order_id
      ,quantity
      ,o.customer_id
      ,c.profile:first_name as f_name
      ,c.profile:last_name as l_name
      ,cast(from_unixtime(order_timestamp, 'yyyy-MM-dd HH:mm:ss') AS timestamp) order_timestamp
      ,o.books
      ,c.profile:address:country as country

  FROM STREAM(LIVE.orders_raw) o
  LEFT JOIN LIVE.customers c
    ON o.customer_id = c.customer_id

-- COMMAND ----------

-- MAGIC %md
-- MAGIC >> Constraint violation
-- MAGIC 
-- MAGIC | **`ON VIOLATION`** | Behavior |
-- MAGIC | --- | --- |
-- MAGIC | **`DROP ROW`** | Discard records that violate constraints |
-- MAGIC | **`FAIL UPDATE`** | Violated constraint causes the pipeline to fail  |
-- MAGIC | Omitted | Records violating constraints will be kept, and reported in metrics |

-- COMMAND ----------

%md
## Gold Tables

-- COMMAND ----------
CREATE OR REFRESH LIVE TABLE cn_daily_customer_books
COMMENT "Daily number of books per customer in China"
AS
  SELECT customer_id, f_name, l_name, date_trunc("DD", order_timestamp) order_date, sum(quantity) books_counts
  FROM LIVE.orders_cleaned
  WHERE country = "China"
  GROUP BY customer_id, f_name, l_name, date_trunc("DD", order_timestamp)

-- COMMAND ---------- ### Once Pipeline is created then create this notebook 
CREATE OR REFRESH LIVE TABLE fr_daily_customer_books
COMMENT "Daily number of books per customer in France"
AS
  SELECT customer_id, f_name, l_name, date_trunc("DD", order_timestamp) order_date, sum(quantity) books_counts
  FROM LIVE.orders_cleaned
  WHERE country = "France"
  GROUP BY customer_id, f_name, l_name, date_trunc("DD", order_timestamp)



--####################### COMMAND #########################----------
# Start again once modified the notebook 
* Workflows => Delta Live Table 
* create Pipeline 
* Piplein Name : demo_bookstore 
* Notebook libraries : ../Delta_live_tables 



# Destination 
 * Storage Location : dbfs:/mnt/demo/dlt/demo_bookstore 
 * Target Shema : demo_bookstore_dlt_db 

# Pipeline mode: triggered

# Cluster Mode : FIXED SIZE 
#Cluster => Workers: 1 



#Policy => DBU/Hour:1
# Advance CONFIGURTION
# datasets.path: dbfs:/mnt/demo-datasets/bookstore 

# CREATE 

# Development: Start 

######## COMPUTE ###########
- JOB COMPUTE SECTION : dlt-execution-0a988662-6d60-4
  # Worker Type: Standard_F8s => 16 GB , 8 Cores , Workers : 1
  # Driver Type: Standard_f8s => 16 GB , 8 Cores 

#################  Data Quality Section #######
- Expectation 
## Compute : Job Cluster # Terminate this pipeline cluster 