variable "environment" {
  description = "The name of the Environment this is deployed into, for example CICD, NFT, UAT or PROD"
}

variable "name" {
  description = "The name of the resource"
}

variable "elasticache_automatic_failover_enabled" {
  description = "should the elasticache automatically failover"
  type        = bool
  default     = true
}

variable "elasticache_azs" {
  description = "Which AZ's to use for elasticache"
  type        = list(string)
}


variable "billing_code_tag" {}
variable "environment_tag" {}
variable "name_prefix" {}
variable "nhs_programme_name" {}
variable "nhs_project_name" {}
variable "service_name" {}
variable "sns_topic" {}
variable "bss_service_tag" {}

variable "bss_sso_rw_user" {}

############################
# BS-SELECT ELASTICACHE REDIS
############################
variable "node_type" {}
variable "engine_version" {}
variable "auto_failover_enabled" {}
variable "number_of_shards" {}
variable "replicas_per_node_group" {}
variable "replication_group_description" {}
variable "multi_az" {}
variable "elasticache_port" {}
variable "apply_immediately" {
  description = "whether to apply changes immediately - false will apply in maintenance window"
  default     = false
}


variable "elasticache_secret_id" {
  description = "The ID for secret in secrets manager"
}
