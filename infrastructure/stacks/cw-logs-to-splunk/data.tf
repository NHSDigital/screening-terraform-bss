data "terraform_remote_state" "cw_firehose_splunk" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_s3_bucket
    key    = "cw-firehose-splunk/terraform.tfstate"
    region = var.aws_region
  }
}
