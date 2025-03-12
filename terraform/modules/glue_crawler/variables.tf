variable "crawler_name" {
  description = "Name of the Glue crawler"
  type        = string
}

variable "database_name" {
  description = "Name of the Glue Catalog Database"
  type        = string
}

variable "s3_target" {
  description = "S3 path to crawl (e.g., processed data folder)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}
