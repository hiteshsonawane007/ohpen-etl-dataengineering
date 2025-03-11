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
