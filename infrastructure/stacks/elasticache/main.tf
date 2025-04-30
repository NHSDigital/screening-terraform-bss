# ######################
# #  Secrets
# ######################

# # connect to AWS secrets manager - arn in tfvars
# data "aws_secretsmanager_secret" "secrets_manager" {
#   name = var.elasticache_secret_id
# }

# # pull secrets out (will be a single JSON blob)
# data "aws_secretsmanager_secret_version" "secrets" {
#   secret_id = data.aws_secretsmanager_secret.secrets_manager.id
# }

# # convert JSON blob into a map that can be referenced
# locals {
#   secrets = jsondecode(
#     data.aws_secretsmanager_secret_version.secrets.secret_string
#   )
# }

# ######################
# #  Texas
# ######################
#  module "texas-info" { 
#     source          = "../../modules/texas-info"
#     aws_region      = var.aws_region
#     domain          = var.domain
#     env             = var.env
# }

# ######################
# #  SNS Topic 
# ######################

# data "aws_sns_topic" "alert" {
#   name = var.sns_topic
# }

# ######################
# #  KMS Key
# ######################

# data "aws_kms_key" "kms_key" {
#   key_id = "alias/${var.bss_service_tag}-${var.env}-shared-kms-key"
# }

# ######################
# #  Elasticache
# ######################

module "elasticache" {
  source          = "./module"
  name            = var.name
  environment     = var.environment
  elasticache_azs = ["eu-west-2a", "eu-west-2b"]
}



# resource "aws_elasticache_replication_group" "elasticache_replication_group" {
#   replication_group_id          = local.replication_group_id
#   description = var.replication_group_description
#   node_type                     = var.node_type
#   transit_encryption_enabled    = true
#   at_rest_encryption_enabled    = true
#   kms_key_id                    = data.aws_kms_key.kms_key.arn
#   auth_token                    = local.secrets.REDIS_PASSWORD
#   port                          = 6379
#   apply_immediately             = var.apply_immediately
#   parameter_group_name          = aws_elasticache_parameter_group.bss_param_group_7.name
#   automatic_failover_enabled    = var.auto_failover_enabled
#   auto_minor_version_upgrade    = true
#   maintenance_window            = "Mon:00:00-Mon:03:00"
#   snapshot_window               = "04:00-08:00"
#   notification_topic_arn        = data.aws_sns_topic.alert.arn
#   subnet_group_name             = aws_elasticache_subnet_group.cache-subnet-group.name
#   security_group_ids            = [ aws_security_group.cache-sg.id ]
#   # TODO: BSS2-183 during the change this var needs to be updated to redis7 per API doc https://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_CacheEngineVersion.html
#   engine_version                = var.engine_version
#   cluster_mode {
#     replicas_per_node_group     = var.replicas_per_node_group
#     num_node_groups             = var.number_of_shards
#   }
#   log_delivery_configuration {
#     destination      = aws_cloudwatch_log_group.redis_engine_log.name
#     destination_type = "cloudwatch-logs"
#     log_format       = "text"
#     log_type         = "engine-log"
#   } 

#   log_delivery_configuration {
#     destination      = aws_cloudwatch_log_group.redis_slow_log.name
#     destination_type = "cloudwatch-logs"
#     log_format       = "text"
#     log_type         = "slow-log"
#   } 

#   tags = {
#     Name        = "BS-Select Cache"
#     BillingCode = var.billing_code_tag
#     Environment = var.environment_tag
#     Programme   = var.nhs_programme_name
#     Project     = var.nhs_project_name
#     Terraform   = true
#     Service     = var.service_name
#   }
# }

# resource "aws_elasticache_parameter_group" "bss_param_group_7" {
#   name   = "${local.parameter_group_name}-redis7"
#   family = "redis7"

#   parameter {
#     name  = "cluster-enabled"
#     value = "yes"
#   }
#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name        = "BS-Select param group"
#     BillingCode = var.billing_code_tag
#     Environment = var.environment_tag
#     Programme   = var.nhs_programme_name
#     Project     = var.nhs_project_name
#     Terraform   = true
#     Service     = var.service_name
#   }
# }

# ######################
# #  Networking
# ######################

# resource "aws_elasticache_subnet_group" "cache-subnet-group" {
#   name        = local.subnet_group
#   description = "Subnet group for Elasticache"
#   subnet_ids  = module.texas-info.private_subnets_ids
# }

# resource "aws_security_group" "cache-sg" {
#   name        = "${var.name_prefix}-${local.sg_name_suffix}"
#   description = "Allow connection by appointed cache clients"
#   vpc_id      = module.texas-info.cluster_vpc_id

#   tags = {
#     Name        = "Security Group for access to elasticache"
#     BillingCode = var.billing_code_tag
#     Environment = var.environment_tag
#     Programme   = var.nhs_programme_name
#     Project     = var.nhs_project_name
#     Terraform   = true
#     Service     = var.service_name
#   }
# }

# resource "aws_security_group_rule" "elasticache_ingress_from_eks_worker" {
#   type                     = "ingress"
#   from_port                = var.elasticache_port
#   to_port                  = var.elasticache_port
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.cache-sg.id
#   source_security_group_id = module.texas-info.eks_worker_sg.id
#   description              = "Allow access in from Eks-worker to elasticache"
# }


# resource "aws_cloudwatch_log_group" "redis_engine_log" {
#   name        = local.cw_redis_engine_log
#   kms_key_id  = data.aws_kms_key.kms_key.arn
#   retention_in_days = 365
#   tags = {
#     Name        = local.cw_redis_engine_log
#     BillingCode = var.billing_code_tag
#     Environment = var.environment_tag
#     Programme   = var.nhs_programme_name
#     Project     = var.nhs_project_name
#     Terraform   = true
#     Service     = var.service_name
#   }
# }

# resource "aws_cloudwatch_log_group" "redis_slow_log" {
#     name        = local.cw_redis_slow_log
#     kms_key_id  = data.aws_kms_key.kms_key.arn
#     retention_in_days = 365
#     tags = {
#       Name        = local.cw_redis_slow_log
#       BillingCode = var.billing_code_tag
#       Environment = var.environment_tag
#       Programme   = var.nhs_programme_name
#       Project     = var.nhs_project_name
#       Terraform   = true
#       Service     = var.service_name
#     }
# }


