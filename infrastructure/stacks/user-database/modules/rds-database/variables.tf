variable "aws_secret_id" {
  type        = string
  description = "The name of the secret that holds the postgresql login details"
}

variable "name" {
  description = "the name of the service"
  type        = string
}

variable "environment" {
  description = "the environment the resource is deployed into"
  type        = string
}

variable "db_name" {
  description = "the name for the users database"
  type        = string
}
