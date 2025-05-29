module "cw-logs-to-splunk" {
  source                    = "../../modules/cw-logs-to-splunk"
  cw_log_group_name         = aws_cloudwatch_log_group.sample_app_log_group.name
  aws_region                = var.aws_region
  terraform_state_s3_bucket = var.terraform_state_s3_bucket
}
