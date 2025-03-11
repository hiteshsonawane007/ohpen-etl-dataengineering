output "glue_job_arn" {
  description = "ARN of the Glue job"
  value       = module.glue.etl_job_arn
}

output "raw_folder_uri" {
  description = "S3 URI for raw data folder"
  value       = "s3://${module.raw.bucket_name}/transactions/raw/"
}

output "processed_folder_uri" {
  description = "S3 URI for processed data folder"
  value       = "s3://${module.processed.bucket_name}/transactions/processed/"
}

output "sns_topic_arn" {
  description = "SNS Topic ARN for alerts"
  value       = module.sns.topic_arn
}
