variable "environment" {
  description = "The name of the Environment this is deployed into, for example CICD, NFT, UAT or PROD"
}

variable "name" {
  description = "The name of the resource"
}

variable "aws_secret_id" {
  type        = string
  description = "The name of the secret that holds the postgresql login details"
}

variable "ingress_cidr" {
  description = "a list of the cidr's that can access the postgresql instance"
  type        = list(string)
}

