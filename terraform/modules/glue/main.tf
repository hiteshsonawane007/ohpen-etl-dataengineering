resource "aws_iam_role" "glue_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "glue.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "glue_policy" {
  name        = "glue_job_policy"
  description = "Policy for the Glue job to access S3 buckets and SNS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        Resource = var.s3_resources
      },
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = var.sns_topic_arn
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}

resource "aws_glue_job" "this" {
  name     = var.job_name
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = var.etl_package_s3_uri
  }

  glue_version = "3.0"
  max_capacity = var.max_capacity

  default_arguments = {
    "--input_s3_folder"  = var.input_folder_uri
    "--output_s3_folder" = var.output_folder_uri
    "--sns_topic_arn"    = var.sns_topic_arn
    "--TempDir"          = var.temp_dir
  }
}
