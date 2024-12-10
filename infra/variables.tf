variable "ENV_NAME" {
  default     = "contabilidade"
  description = "Terraform environment name"
}

variable "AWS_REGION" {
  default     = "us-east-1"
  description = "AWS Region to deploy to"
}

variable "AWS_ACCESS_KEY_ID" {
  default   = ""
  sensitive = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  default   = ""
  sensitive = true
}

variable "AWS_S3_BUCKET_NAME" {
  default   = "contabilidade-bucket-rdg"
  sensitive = true
}