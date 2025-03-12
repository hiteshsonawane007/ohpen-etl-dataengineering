resource "aws_glue_catalog_database" "this" {
  name = var.database_name
}

resource "aws_glue_crawler" "this" {
  name          = var.crawler_name
  role          = var.role_arn
  database_name = aws_glue_catalog_database.this.name

  s3_target {
    path = var.s3_target
  }

  configuration = jsonencode({
    Version         = 1.0,
    CrawlerOutput   = {
      Partitions  = {
        AddOrUpdateBehavior = "InheritFromTable"
      }
    }
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
          "glue:CreateTable",        // if needed
          "glue:UpdateTable"         // if needed
        ],
        "Resource": [
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/etl_database",
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/etl_database/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_crawler_attach" {
  role       = var.crawler_role_arn
  policy_arn = aws_iam_policy.glue_crawler_policy.arn
}

data "aws_caller_identity" "current" {}

