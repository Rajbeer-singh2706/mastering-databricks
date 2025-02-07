# Databricks notebook source
%md-sandbox
<div  style="text-align: center; line-height: 0; padding-top: 9px;">
  <img src="https://dalhussein.blob.core.windows.net/course-resources/bookstore_schema.png" alt="Databricks Learning" style="width: 600">
</div>

-- COMMAND ----------
%run ../Includes/Copy-Datasets

--- COMMAND ----------
(spark.readStream
      .table("books")
      .createOrReplaceTempView("books_streaming_tmp_vw")
)

-- COMMAND ----------
SELECT * FROM books_streaming_tmp_vw

-- COMMAND ----------
SELECT author, count(book_id) AS total_books
FROM books_streaming_tmp_vw
GROUP BY author

-- COMMAND ----------AnalysisException: Sorting is not supported on streaming DataFrames/Datasets,
SELECT * 
FROM books_streaming_tmp_vw
ORDER BY author

-- COMMAND ----------
CREATE OR REPLACE TEMP VIEW author_counts_tmp_vw AS (
   SELECT author, count(book_id) AS total_books
   FROM books_streaming_tmp_vw
   GROUP BY author
)

-- COMMAND ----------
(spark.table("author_counts_tmp_vw")                               
      .writeStream  
      .trigger(processingTime='4 seconds')
      .outputMode("complete")
      .option("checkpointLocation", "dbfs:/mnt/demo/author_counts_checkpoint")
      .table("author_counts")
)

-- COMMAND ----------
SELECT * FROM author_counts

--  COMMAND ----------
INSERT INTO books
values ("B19", "Introduction to Modeling and Simulation", "Mark W. Spong", "Computer Science", 25),
         ("B20", "Robot Modeling and Control", "Mark W. Spong", "Computer Science", 30),
         ("B21", "Turing's Vision: The Birth of Computer Science", "Chris Bernhardt", "Computer Science", 35)

-- COMMAND ----------
 INSERT INTO books
 values ("B16", "Hands-On Deep Learning Algorithms with Python", "Sudharsan Ravichandiran", "Computer Science", 25),
         ("B17", "Neural Network Methods in Natural Language Processing", "Yoav Goldberg", "Computer Science", 30),
         ("B18", "Understanding digital signal processing", "Richard Lyons", "Computer Science", 35)

--- COMMAND ----------
(spark.table("author_counts_tmp_vw")                               
      .writeStream           
      .trigger(availableNow=True)
      .outputMode("complete")
      .option("checkpointLocation", "dbfs:/mnt/demo/author_counts_checkpoint")
      .table("author_counts")
      .awaitTermination()
)

-- COMMAND ----------
SELECT * FROM author_counts

-- COMMAND ----------