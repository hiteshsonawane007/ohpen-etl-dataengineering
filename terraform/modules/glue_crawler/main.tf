resource "aws_glue_catalog_database" "this" {
  name = var.database_name
}

resource "aws_iam_role" "crawler_role" {
  name = "${var.crawler_name}_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "glue.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "glue_crawler_policy" {
  name        = "GlueCrawlerPolicy"
  description = "Policy for Glue crawler to access Glue Catalog databases and tables"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:BatchGetPartition",
          "glue:BatchCreatePartition"
        ],
        "Resource": [
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/etl_database",
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/etl_database/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::ohpen-etl-processed-financial-data"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject"
        ],
        "Resource": [
          "arn:aws:s3:::ohpen-etl-processed-financial-data/transactions/processed/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_crawler_attach" {
  role       = aws_iam_role.crawler_role.name
  policy_arn = aws_iam_policy.glue_crawler_policy.arn
}

data "aws_caller_identity" "current" {}

resource "aws_glue_crawler" "this" {
  name          = var.crawler_name
  role          = aws_iam_role.crawler_role.arn
  database_name = aws_glue_catalog_database.this.name

  s3_target {
    path = var.s3_target
  }

  configuration = jsonencode({
    "Version": 1.0,
    "CrawlerOutput": {
      "Partitions": { "AddOrUpdateBehavior": "InheritFromTable" }
    },
    "SchemaChangePolicy": {
      "UpdateBehavior": "UPDATE_IN_DATABASE",  // Automatically update the table schema with new columns
      "DeleteBehavior": "LOG"                   // Log removals rather than deleting columns
    }
  })
}