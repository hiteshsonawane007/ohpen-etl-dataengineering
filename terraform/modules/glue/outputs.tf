output "etl_job_arn" {
  description = "ARN of the Glue ETL job"
  value       = aws_glue_job.this.arn
}
output "glue_role_arn" {
  description = "ARN of the IAM role used by the Glue job"
  value       = aws_iam_role.glue_role.arn
}
