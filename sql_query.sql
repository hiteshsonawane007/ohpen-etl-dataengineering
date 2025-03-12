SELECT * FROM "AwsDataCatalog"."etl_database"."processed" limit 10;


SELECT 
  account_id,
  date_trunc('month', transactiontimestamp) AS month_start,
  MAX(new_balance) AS end_of_month_balance
FROM "AwsDataCatalog"."etl_database"."processed"
WHERE transactiontimestamp >= TIMESTAMP '2025-01-01 00:00:00'
  AND transactiontimestamp < TIMESTAMP '2025-04-01 00:00:00'
GROUP BY account_id, date_trunc('month', transactiontimestamp)
ORDER BY account_id, month_start;

