variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "folder_keys" {
  description = "List of folder keys to create in the bucket"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the bucket"
  type        = map(string)
  default     = {}
}
