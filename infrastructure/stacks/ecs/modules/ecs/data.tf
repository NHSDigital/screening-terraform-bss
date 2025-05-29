data "aws_secretsmanager_secret" "account_ids" {
  name = "aws_account_ids"
}

data "aws_secretsmanager_secret_version" "account_ids" {
  secret_id = data.aws_secretsmanager_secret.account_ids.id
}

locals {
  aws_account_ids      = jsondecode(data.aws_secretsmanager_secret_version.account_ids.secret_string)
  live_mgmt_account_id = local.aws_account_ids["live-mgmt"]
  local_account_id     = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_s3_bucket
    key    = "vpc/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "security-groups" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_s3_bucket
    key    = "security-groups/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "route53" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_s3_bucket
    key    = "route53/terraform.tfstate"
    region = var.aws_region
  }
}

