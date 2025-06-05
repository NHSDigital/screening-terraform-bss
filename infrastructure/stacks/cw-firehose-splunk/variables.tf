
variable "secret_data" {
  # TODO - pull in the Splunk HEC token from secrets manager instead of manual input
  description = "combined secret string (Splunk HEC token followed by ~ followed by true or false for exclude_extra_logging value)"
  sensitive   = true
}
variable "firehose_splunk_url" {
  description = "URL for splunk"
  default     = "https://firehose.inputs.splunk.aws.digital.nhs.uk/services/collector"
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

variable "environment" {
  description = "The name of the Environment this is deployed into, for example CICD, NFT, UAT or PROD"
  type        = string
}
