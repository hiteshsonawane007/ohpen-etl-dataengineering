# terraform/variables.tf

variable "region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "us-east-1"
}

variable "glue_job_name" {
  description = "Name of the AWS Glue Job"
  type        = string
  default     = "financial-etl-job"
}

variable "role_name" {
  description = "Name of the IAM role for the AWS Glue job"
  type        = string
  default     = "glue_job_role"
}
