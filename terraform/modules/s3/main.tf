resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket_object" "folders" {
  for_each = toset(var.folder_keys)
  bucket   = aws_s3_bucket.this.bucket
  key      = each.value
  content  = ""
}

# Upload ETL ZIP package to the input bucket.
resource "aws_s3_bucket_object" "glue_etl_package" {
  bucket       = aws_s3_bucket.input_bucket.bucket
  key          = "etl/etl_package.zip"
  source       = "../etl_package.zip"  # Adjust the path relative to your terraform directory.
  etag         = filemd5("../etl_package.zip")
  content_type = "application/zip"
}