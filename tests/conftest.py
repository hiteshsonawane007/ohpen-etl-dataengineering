# tests/conftest.py

import pytest
from pyspark.sql import SparkSession
import os
import sys

# Add the project root (one directory above "tests/") to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))


@pytest.fixture(scope="session")
def spark():
    spark = SparkSession.builder \
        .master("local[2]") \
        .appName("PyTestETL") \
        .getOrCreate()
    yield spark
    spark.stop()
