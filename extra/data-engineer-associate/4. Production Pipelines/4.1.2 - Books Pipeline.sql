-- Databricks notebook source

-- COMMAND ----------
%md
## Bronze Layer Tables
CREATE OR REFRESH STREAMING LIVE TABLE books_bronze
COMMENT "The raw books data, ingested from CDC feed"
AS SELECT * FROM cloud_files("${datasets_path}/books-cdc", "json")

-- COMMAND ----------
%md
## Silver Layer Tables
CREATE OR REFRESH STREAMING LIVE TABLE books_silver;

APPLY CHANGES INTO LIVE.books_silver
  FROM STREAM(LIVE.books_bronze)
  KEYS (book_id)
  APPLY AS DELETE WHEN row_status = "DELETE"
  SEQUENCE BY row_time
  COLUMNS * EXCEPT (row_status, row_time)

-- COMMAND ----------
%md
## Gold Layer Tables

-- COMMAND ----------
CREATE LIVE TABLE author_counts_state
  COMMENT "Number of books per author"
AS SELECT author, count(*) as books_count, current_timestamp() updated_time
  FROM LIVE.books_silver
  GROUP BY author

-- COMMAND ----------
-- MAGIC %md
-- MAGIC ## DLT Views
CREATE LIVE VIEW books_sales
  AS SELECT b.title, o.quantity
    FROM (
      SELECT *, explode(books) AS book 
      FROM LIVE.orders_cleaned) o
    INNER JOIN LIVE.books_silver b
    ON o.book.book_id = b.book_id;
  

###################################
# Setting 
# ADd notebook Librarire 
# 4.12 books pipeline 

# Start
  # Start : Only latest changes 
  # Full Refresh All > It will do everythig from scratch 