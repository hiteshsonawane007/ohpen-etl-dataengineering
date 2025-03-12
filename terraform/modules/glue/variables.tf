variable "role_name" {
  description = "IAM role name for the Glue job"
  type        = string
}

variable "job_name" {
  description = "Name of the Glue job"
  type        = string
}

variable "etl_package_s3_uri" {
  description = "S3 URI of the ETL package ZIP file"
  type        = string
}

variable "max_capacity" {
  description = "Maximum capacity (in DPUs) for the Glue job"
  type        = number
  default     = 2
}

variable "input_folder_uri" {
  description = "S3 URI for the input (raw data) folder"
  type        = string
}

variable "output_folder_uri" {
  description = "S3 URI for the output (processed data) folder"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN to send alerts"
  type        = string
}

variable "temp_dir" {
  description = "Temporary directory for Glue job"
  type        = string
  default     = ""
}

variable "s3_resources" {
  description = "A list of S3 ARNs which the Glue job is allowed to access"
  type        = list(string)
}
variable "crawler_role_arn" {
  description = "IAM Role ARN for the Glue crawler"
  type        = string
}
