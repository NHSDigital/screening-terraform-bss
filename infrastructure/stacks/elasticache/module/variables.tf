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

variable "description" {
  description = "A description of the elasticache cluster"
  type        = string
  default     = "An elasticache cluster"
}

variable "elasticache_node_type" {
  description = "which size node should be used"
  type        = string
  default     = "cache.m4.large"
}

variable "elasticache_cluster_count" {
  description = "Number of cache clusters"
  type        = number
  default     = 2
}

variable "elasticache_parameter_group_name" {
  description = "The parameter group to use"
  type        = string
  default     = "default.redis3.2"
}

variable "elasticache_port" {
  description = "The port to use for connecting to the cluster"
  type        = number
  default     = 6379
}

variable "elasticache_encryption_in_transit" {
  description = "Enable encryption for inbound and outbound connections"
  type        = bool
  default     = true
}

variable "elasticache_encryption_at_rest" {
  description = "Enable encryption for stored data"
  type        = bool
  default     = true
}
