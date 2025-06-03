variable "aws_secret_id" {
  type        = string
  description = "The name of the secret that holds the postgresql login details"
}

variable "name" {
  description = "the name of the RDS instance"
  type        = string
  default     = ""
}

variable "environment" {
  description = "the environment the resource is deployed into"
  type        = string
}

variable "db_name" {
  description = "Name of the branch used to create the database"
}

variable "name_prefix" {
  description = "The name prefix which includes environment and region details"
  type        = string
}

