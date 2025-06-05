data "terraform_remote_state" "cw_firehose_splunk" {
  backend = "s3"

  config = {
    bucket = "nhse-bss-cicd-state"
    key    = "terraform-state/firehose-splunk.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "True"
      Stack       = "SUBSCRIPTION_FILTER"
    }
  }
}
