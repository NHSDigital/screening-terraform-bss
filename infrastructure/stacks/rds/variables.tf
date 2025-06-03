variable "name" {
  description = "The name of the resource"
  type        = string
  default     = "postgres"
}

variable "aws_secret_id" {
  type        = string
  description = "The name of the secret that holds the postgresql login details"
}

variable "ingress_cidr" {
  description = "a list of the cidr's that can access the postgresql instance"
  type        = list(string)
}

variable "name_prefix" {
  description = "The account, environment etc"
  type        = string
}

variable "aws_account_id" {
  sensitive   = true
  description = "The AWS account ID"
  type        = string
}

variable "environment" {
  description = "The name of the Environment this is deployed into, for example CICD, NFT, UAT or PROD"
  type        = string
}

variable "vpc_name" {
  description = "vpc name"
  type        = string
  default     = ""
}
