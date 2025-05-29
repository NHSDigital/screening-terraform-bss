variable "name_prefix" {
  description = "The account, environment etc"
  type        = string
}

variable "aws_account_id" {
  sensitive   = true
  description = "The AWS account ID"
  type        = string
}

