# etl/utils.py

import logging
from pyspark.sql.functions import col
#from . import config  # Relative import of config module
import config

logger = logging.getLogger(__name__)

def validate_data(df):
    """
    Validate the DataFrame by ensuring:
      - Critical fields (TransactionID, CustomerID, TransactionAmount, TransactionTimestamp) are not null.
      - Currency codes must be in config.VALID_CURRENCIES.
    
    Any records failing these conditions are filtered out.
    """
    try:
        # Display the DataFrame for debugging (use df.collect() for small DataFrame if needed)
        df.show(truncate=False)
        
        initial_count = df.count()
        
        df_valid = df.filter(
            col("TransactionID").isNotNull() &
            col("CustomerID").isNotNull() &
            col("TransactionAmount").isNotNull() &
            col("TransactionTimestamp").isNotNull() &
            col("Currency").isin(list(config.VALID_CURRENCIES))
        )
        
        final_count = df_valid.count()
        invalid_records = initial_count - final_count
        if invalid_records > 0:
            logger.warning("Validation removed %s records due to missing/invalid values.", invalid_records)
        if final_count == 0:
            raise ValueError("No valid data found")
        
        return df_valid
    except Exception as e:
        logger.error("An error occurred during data validation: %s", e)
        raise
