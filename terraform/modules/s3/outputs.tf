output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "etl_package_s3_uri" {
  description = "S3 URI of the ETL package ZIP file"
  value       = var.upload_zip ? "s3://${aws_s3_bucket.this.bucket}/etl/etl_package.zip" : ""
}