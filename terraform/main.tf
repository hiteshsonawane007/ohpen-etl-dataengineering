# S3 Buckets and Glue Job Configuration

resource "aws_s3_bucket" "input_bucket" {
  bucket = "ohpen-etl-raw-financial-data"

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

  tags = {
    Name        = "ETL Raw Financial Data"
    Environment = "production"
  }
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "ohpen-etl-processed-financial-data"

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

  tags = {
    Name        = "ETL Processed Financial Data"
    Environment = "production"
  }
}

resource "aws_s3_bucket_object" "glue_etl_script" {
  bucket       = aws_s3_bucket.input_bucket.bucket
  key          = "etl/glue_job.py"
  source       = "../etl/glue_job.py"
  etag         = filemd5("../etl/glue_job.py")
  content_type = "text/x-python"
}

resource "aws_iam_role" "glue_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "glue_policy" {
  name        = "glue_job_policy"
  description = "Policy for Glue job to access S3 buckets"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::ohpen-etl-raw-financial-data",
          "arn:aws:s3:::ohpen-etl-raw-financial-data/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject"
        ],
        "Resource": [
          "arn:aws:s3:::ohpen-etl-processed-financial-data",
          "arn:aws:s3:::ohpen-etl-processed-financial-data/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}

resource "aws_glue_job" "etl_job" {
  name     = var.glue_job_name
  role_arn = aws_iam_role.glue_role.arn
  
  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.input_bucket.bucket}/${aws_s3_bucket_object.glue_etl_script.key}"
  }

  glue_version = "3.0"
  max_capacity = 2
}
