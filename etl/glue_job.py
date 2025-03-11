# etl/glue_job.py

import sys
import logging
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, year, month, to_timestamp
from .utils import validate_data  # Using relative import
from . import config           # Using relative import

# Configure logging
logging.basicConfig(level=config.LOG_LEVEL)
logger = logging.getLogger(__name__)

def process_data(input_path, output_path):
    # Create a Spark session
    spark = SparkSession.builder.appName(config.APP_NAME).getOrCreate()
    
    # Read CSV data from input S3 path (assumes header is present)
    df = spark.read.option("header", True).csv(input_path)
    logger.info("CSV data loaded successfully from %s", input_path)
    
    # Convert the TransactionTimestamp column from string to timestamp type
    df = df.withColumn("TransactionTimestamp", to_timestamp(col("TransactionTimestamp")))
    
    # Validate data (this filters out records with missing critical fields or invalid currency)
    df_valid = validate_data(df)
    
    # Add partition columns: 'year' and 'month'
    df_partitioned = df_valid.withColumn("year", year(col("TransactionTimestamp"))) \
                             .withColumn("month", month(col("TransactionTimestamp")))
    
    # Write output as Parquet, partitioned by year and month
    df_partitioned.write.mode("overwrite") \
        .partitionBy("year", "month") \
        .parquet(output_path)
    
    logger.info("Data processing complete. Output written to %s", output_path)
    spark.stop()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("Required inputs Missing: glue_job.py <input_s3_path> <output_s3_path>")
    
    input_s3_path = sys.argv[1]
    output_s3_path = sys.argv[2]
    
    process_data(input_s3_path, output_s3_path)
