variable "cw_log_group_name" {

}

variable "filter_pattern" {
  nullable = false
  default  = ""
}

variable "environment" {
  description = "The name of the Environment this is deployed into, for example CICD, NFT, UAT or PROD"
  type        = string
}
