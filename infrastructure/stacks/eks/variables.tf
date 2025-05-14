variable "environment" {
  description = "The name of the Environment this is deployed into, for example CICD, NFT, UAT or PROD"
}

variable "name" {
  description = "The name of the resource"
}

variable "cluster_version" {
  description = "The version of kubernetes to deploy"
  default     = "1.32"
}
