# etl/glue_job.py

import sys
import logging
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, year, month, to_timestamp
from etl import utils
from etl import config
from awsglue.utils import getResolvedOptions
import boto3

# Configure logging
logging.basicConfig(level=config.LOG_LEVEL)
logger = logging.getLogger(__name__)

def send_alert(total_records, error_count, sns_topic_arn):
    """Send alert via SNS with key metrics."""
    sns = boto3.client("sns")
    message = (
        f"Glue ETL Job Run Summary:\n"
        f"Total Records Processed: {total_records}\n"
        f"Errors Encountered: {error_count}\n"
    )
    subject = "Glue ETL Job Run Summary"
    response = sns.publish(
        TopicArn=sns_topic_arn,
        Message=message,
        Subject=subject
    )
    logger.info("Alert response: %s", response)
    return response

def process_data(input_s3_folder, output_s3_folder, sns_topic_arn):
    # Create a Spark session
    spark = SparkSession.builder.appName(config.APP_NAME).getOrCreate()
    
    # Read CSV data from input S3 path (assumes header is present)
    df = spark.read.option("header", True).csv(input_s3_folder)
    logger.info("CSV data loaded successfully from %s", input_s3_folder)
    
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
        .parquet(output_s3_folder)
    total_records = df_partitioned.count()
    error_count = 0  # Update with actual error metrics if available
    send_alert(total_records, error_count, sns_topic_arn)
    
    logger.info("Data processing complete. Output written to %s", output_s3_folder)
    spark.stop()

def main():
    args = getResolvedOptions(sys.argv, ['JOB_NAME', 'input_s3_folder', 'output_s3_folder', 'sns_topic_arn'])
    input_s3_folder = args['input_s3_folder']
    output_s3_folder = args['output_s3_folder']
    sns_topic_arn = args['sns_topic_arn']
    process_data(input_s3_folder, output_s3_folder, sns_topic_arn)
    
if __name__ == "__main__":
    main()
