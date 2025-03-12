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

variable "role_arn" {
  description = "IAM role ARN for the Glue crawler"
  type        = string
}

variable "crawler_role_arn" {
  description = "IAM role ARN to be used by the Glue crawler"
  type        = string
}
