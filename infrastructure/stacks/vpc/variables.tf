variable "environment" {
  description = "The name of the Environment this is deployed into, for example CICD, NFT, UAT or PROD"
}

variable "name" {
  description = "The name of the resource"
  default     = ""
}

variable "name_prefix" {
  description = "the prefix for the name which containts the environment and business unit"
  type        = string
}

