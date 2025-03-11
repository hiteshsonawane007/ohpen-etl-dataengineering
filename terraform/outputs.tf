output "glue_job_name" {
  description = "The name of the AWS Glue job"
  value       = aws_glue_job.etl_job.name
}

output "glue_role_arn" {
  description = "The ARN for the IAM role attached to the Glue job"
  value       = aws_iam_role.glue_role.arn
}

output "glue_etl_script_location" {
  description = "The S3 URI of the uploaded Glue ETL script"
  value       = "s3://${aws_s3_bucket.input_bucket.bucket}/${aws_s3_bucket_object.glue_etl_script.key}"
}
