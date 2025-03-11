output "etl_job_arn" {
  description = "ARN of the Glue ETL job"
  value       = aws_glue_job.this.arn
}
