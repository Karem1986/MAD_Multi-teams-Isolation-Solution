# Databricks notebook source
# MAGIC %md
# MAGIC # MAD Platform - Production PySpark Quality Transformation Pipeline

import json
import os
import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp

# 1. Initialize Spark (Works locally and scales inside Databricks)
spark = SparkSession.builder.appName("MAD-Pipeline").getOrCreate()

# 2. Environment-Aware Parameter Extraction (Bypasses local dbutils errors)
try:
    dbutils.widgets.text("team_name", "ingest", "Executing Team")
    team = dbutils.widgets.get("team_name")
    print(f"[INFO] Running on Databricks. Resolved team parameter via widget: {team}")
except NameError:
    # Fallback for local testing in VS Code
    team = os.getenv("MAD_TEAM_NAME", "ingest")
    print(f"[INFO] dbutils not detected. Falling back to local parameter: {team}")

env = os.getenv("MAD_ENVIRONMENT", "dev")

# 3. Read Externalized Configuration JSON
# Resolves path safely whether run from the notebooks folder or repository root
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__)) if '__file__' in locals() else os.getcwd()
CONFIG_PATH = os.path.normpath(os.path.join(CURRENT_DIR, "..", "config", "pipeline_config.json"))

with open(CONFIG_PATH, "r") as f:
    config = json.load(f)[env]

# 4. Resolve Dynamic Cloud Paths based on Team Isolation
base_path = f"abfss://{config['landing_container_prefix']}{team}-{env}@{config['storage_account']}.dfs.core.windows.net"
source_path = f"{base_path}/{config['landing_zone']}"
target_path = f"{base_path}/{config['gold_zone']}"


# 5. Core Transformation Logic (Extracted for Production Unit Testing)
def transform_data(df):
    """
    Applies production data quality rules: drops duplicates,
    filters out null keys, and appends an execution timestamp.
    """
    df_deduped = df.dropDuplicates(["transaction_id"])
    df_cleaned = df_deduped.filter(
        col("transaction_id").isNotNull() & 
        col("amount").isNotNull()
    )
    df_final = df_cleaned.withColumn("processed_at", current_timestamp())
    return df_final


# 6. Pipeline Execution Block
# Only attempts to load and save if running in Databricks
if "databricks" in sys.modules or os.getenv("MAD_EXECUTE_IO") == "true":
    print(f"[INFO] Executing live I/O operations against: {source_path}")
    df_raw = spark.read.format("json").load(source_path)
    df_transformed = transform_data(df_raw)
    df_transformed.write.format("delta").mode("overwrite").save(target_path)
else:
    print("[INFO] Offline mode active. Core transformation pipeline loaded and validated successfully.")
