# terraform/variables.tf

variable "region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "eu-north-1"
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

variable "sns_topic_email" {
  description = "Email address for SNS alerts"
  type        = string
  default     = "hitesh.sonawane8329@gmail.com"   # Change to the desired email
}

# This variable is used by the glue crawler module for its role policy
variable "crawler_role_arn" {
  description = "IAM Role ARN for the Glue crawler (if providing externally)"
  type        = string
  default     = ""
}