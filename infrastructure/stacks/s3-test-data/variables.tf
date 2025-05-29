variable "environment" {
  description = "The name of the Environment this is deployed into, for example CICD, NFT, UAT or PROD"
  type        = string
}

variable "name_prefix" {
  description = "provides the prefix to keep consistancy"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account number"
  type        = string
}

variable "name" {
  description = "bucket name"
  type        = string
}

variable "bucket_name" {
  description = "Name for the bucket"
  type        = string
  default     = "test-data"
}

