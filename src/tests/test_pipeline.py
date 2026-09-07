# Validates pipeline data quality rules without requiring cloud connectivity.
#SLIDE 9 quality gates
import pytest
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, DoubleType
import sys
import os

# 1. Establish Absolute Runtime Path Resolution
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__)) if '__file__' in locals() else os.getcwd()
NOTEBOOKS_DIR = os.path.normpath(os.path.join(CURRENT_DIR, "..", "notebooks"))

if NOTEBOOKS_DIR not in sys.path:
    sys.path.append(NOTEBOOKS_DIR)

from data_pipeline import transform_data

# 2. PyTest Fixtures
@pytest.fixture(scope="session")
def spark_session():
    """Provides a localized, lightweight Spark engine for schema and logic validation."""
    spark = SparkSession.builder \
        .master("local[1]") \
        .appName("pyspark-unit-testing") \
        .config("spark.ui.enabled", "false") \
        .config("spark.sql.shuffle.partitions", "1") \
        .config("spark.default.parallelism", "1") \
        .config("spark.sql.session.timeZone", "UTC") \
        .getOrCreate()
        
    spark.sparkContext.setLogLevel("ERROR")
    yield spark
    spark.stop()


# 3. Automated Test Implementations
def test_transform_data_quality_gates(spark_session):
    """
    Verifies that duplicate transactions and critical null values 
    are strictly dropped while appending metadata tracking fields.
    """
    # Define explicit input schema
    schema = StructType([
        StructField("transaction_id", StringType(), True),
        StructField("customer_id", StringType(), True),
        StructField("amount", DoubleType(), True)
    ])
    
    # Mock data capturing exact real-world pipeline scenarios
    mock_input_data = [
        ("TXN_100", "CUST_A", 150.50),  # Record 1: Valid record
        ("TXN_100", "CUST_A", 150.50),  # Record 2: Duplicate key (Should be dropped)
        (None,      "CUST_B", 200.00),  # Record 3: Missing Transaction ID (Should be dropped)
        ("TXN_200", "CUST_C", None)     # Record 4: Missing Amount Value (Should be dropped)
    ]
    
    # Instantiate the test DataFrame
    df_mock_input = spark_session.createDataFrame(mock_input_data, schema)
    
    # Execute the pipeline transformation function
    df_output = transform_data(df_mock_input)
    output_records = df_output.collect()
    
    # --- QUALITY ASSURANCES (THE GATES) ---
    
    # Gate A: Volume verification (4 records input -> exactly 1 valid record should survive)
    assert len(output_records) == 1, f"Expected exactly 1 clean record, got {len(output_records)}"
    
    # Gate B: Integrity verification (The correct surviving record must match our expected transaction)
    assert output_records[0]["transaction_id"] == "TXN_100", "The data pipeline outputted the wrong record."
    
    # Gate C: Governance verification (Auditing timestamp must exist in the output schema)
    assert "processed_at" in df_output.columns, "Audit column 'processed_at' was not appended to the output schema."
