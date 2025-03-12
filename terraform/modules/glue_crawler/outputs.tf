output "database_name" {
  description = "Name of the Glue Catalog Database created"
  value       = aws_glue_catalog_database.this.name
}

output "crawler_role_arn" {
  description = "IAM Role ARN used by the Glue crawler"
  value       = aws_iam_role.crawler_role.arn
}
