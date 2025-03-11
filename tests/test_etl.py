# tests/test_etl.py

import pytest
from pyspark.sql.functions import to_timestamp
from pyspark.sql.types import StructType, StructField, StringType, DoubleType
from etl.utils import validate_data


def test_validate_data(spark):
    data = [
        ("txn_001", "cust_001", 100.0, "USD", "2021-07-01 10:00:00"),
        (None, "cust_002", 200.0, "EUR", "2021-07-01 11:00:00"),
        ("txn_003", "cust_003", 150.0, "ABC", "2021-07-01 12:00:00")
    ]
    schema = StructType([
        StructField("TransactionID", StringType(), True),
        StructField("CustomerID", StringType(), True),
        StructField("TransactionAmount", DoubleType(), True),
        StructField("Currency", StringType(), True),
        StructField("TransactionTimestamp", StringType(), True)
    ])
    df = spark.createDataFrame(data, schema=schema)
    df = df.withColumn("TransactionTimestamp", to_timestamp("TransactionTimestamp"))
    df_valid = validate_data(df)
    assert df_valid.count() == 1

def test_validate_data_all_valid(spark):
    data = [
        ("txn_001", "cust_001", 100.0, "USD", "2025-03-01 10:00:00"),
        ("txn_002", "cust_002", 200.0, "EUR", "2025-03-02 11:00:00")
    ]
    columns = [
        "TransactionID", 
        "CustomerID", 
        "TransactionAmount", 
        "Currency", 
        "TransactionTimestamp"
    ]
    df = spark.createDataFrame(data, columns)
    df = df.withColumn("TransactionTimestamp", to_timestamp("TransactionTimestamp"))
    df_valid = validate_data(df)
    assert df_valid.count() == 2

pytest.raises(ValueError, match="Some of types cannot be determined after inferring")
def test_validate_data_no_valid(spark):
    data = [
        (None, "cust_001", 100.0, "ABC", "2021-07-01 10:00:00"),
        (None, "cust_002", 200.0, "XYZ", "2021-07-01 11:00:00")
    ]
    columns = [
        "TransactionID", 
        "CustomerID", 
        "TransactionAmount", 
        "Currency", 
        "TransactionTimestamp"
    ]
    df = spark.createDataFrame(data, columns)
    df = df.withColumn("TransactionTimestamp", to_timestamp("TransactionTimestamp"))
    df_valid = validate_data(df)
    assert df_valid.count() == 0
