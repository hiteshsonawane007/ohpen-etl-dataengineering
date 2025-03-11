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

# New variables for ZIP package upload
variable "upload_zip" {
  description = "Whether to upload a zip file into the bucket"
  type        = bool
  default     = false
}

variable "zip_source" {
  description = "Local file path of the zip file to upload"
  type        = string
  default     = ""
}