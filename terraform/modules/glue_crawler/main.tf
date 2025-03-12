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

