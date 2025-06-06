
resource "aws_cloudwatch_log_subscription_filter" "cw_to_splunk_subscription_filter" {
  name            = "cw_to_splunk_subscription_filter"
  log_group_name  = var.cw_log_group_name
  destination_arn = data.terraform_remote_state.cw_firehose_splunk.outputs.cw_to_splunk_firehose_stream_arn
  filter_pattern  = var.filter_pattern
  role_arn        = data.terraform_remote_state.cw_firehose_splunk.outputs.cw_to_splunk_firehose_role_arn
}
