##################################################################################
# INFRASTRUCTURE COMPONENT VERSION
##################################################################################
variable "version_tag" {
  description = "The infrastructure component version assigned by Texas development. The version MUST be incremented when changed <major version>.<minor version>"
  default     = "1.0"
}

##################################################################################
# AWS COMMON
##################################################################################
variable "terraform_state_s3_bucket" {
  description = "Name of the S3 bucket used to store the Terraform state"
}

variable "aws_region" {
  description = "The AWS region"
}

#######
# TEXAS COMMON
#######
variable "envdomain" {
  description = "The environment-related part of the domain e.g. texasdev, texastest or texasplatform"
}

variable "env2" {
  description = "dev, nonprod, prod"
}

variable "envtype1" {
  description = "The environment type used in AWS resource names (format 1) - either k8s or mgmt"
}

variable "envtype2" {
  description = "The environment type used in AWS resource names (format 2) - either lk8s or mgmt"
}

variable "subenv" {
  description = "The sub-environment where multiple enviroments are contained within a primary environment e.g. prod & nonprod within live. Must be either '', '-nonprod' or '-prod' - note the hyphens!"
}

variable "infrastructure_tag" {
  description = "Infrastructure tag to identify the owner of the resource"
}


variable "service_prefix" {
  description = "Service team prefix"
  default     = "texas"
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
