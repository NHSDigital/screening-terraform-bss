variable "environment" {
  description = "The name of the Environment this is deployed into, for example CICD, NFT, UAT or PROD"
  type        = string
}

variable "thumbprint" {
  description = "The public thumbprint for github"
  type        = string
  default     = "3294906e7ed1fe0645d45c2cde1f09a1c8d62b73"
}

