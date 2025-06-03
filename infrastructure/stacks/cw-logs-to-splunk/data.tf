data "terraform_remote_state" "cw_firehose_splunk" {
  backend = "s3"

  config = {
    bucket = "nhse-bss-cicd-state"
    key    = "terraform-state/firehose-splunk.tfstate"
    region = "eu-west-2"
  }
}

terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/firehose-subscription-filter.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
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