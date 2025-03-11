# etl/config.py

# S3 Bucket Configuration
INPUT_BUCKET = "raw-financial-data"
OUTPUT_BUCKET = "processed-financial-data"

# Folder paths for organizing files in S3
RAW_DATA_FOLDER = "transactions/raw"
PROCESSED_DATA_FOLDER = "transactions/processed"

# Application Settings
APP_NAME = "FinancialETLApp"
LOG_LEVEL = "INFO"  # Change to "DEBUG" for detailed logs

# Data Validation Settings
VALID_CURRENCIES = {"USD", "EUR", "GBP"}
