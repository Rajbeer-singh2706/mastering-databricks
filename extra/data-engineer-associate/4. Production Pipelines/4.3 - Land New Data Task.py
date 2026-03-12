# Databricks notebook source
# MAGIC %run ../Includes/Copy-Datasets

# COMMAND ----------
load_new_json_data()


%sql 
select * from json.`${dataset.bookstore}/books-cdc/02.json`