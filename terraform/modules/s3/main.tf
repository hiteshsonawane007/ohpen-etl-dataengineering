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
resource "aws_s3_bucket_object" "etl_package" {
  count         = var.upload_zip ? 1 : 0
  bucket        = aws_s3_bucket.this.bucket
  key           = "etl/etl_package.zip"
  source        = var.zip_source
  etag          = filemd5(var.zip_source)
  content_type  = "application/zip"
}