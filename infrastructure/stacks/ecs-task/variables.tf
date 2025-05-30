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

variable "container_port" {
  description = "The port for the container"
  type        = number
  default     = 4000
}

variable "name" {
  description = "The name"
  type        = string
  default     = "-test"
}

variable "cluster_name" {
  description = "cluster name"
  type        = string
  default     = "-ecs"
}

variable "vpc_name" {
  description = "vpc name"
  type        = string
  default     = ""
}
