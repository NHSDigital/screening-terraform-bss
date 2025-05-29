terraform {
  backend "s3" {
    encrypt = true
    # Other parameters are defined at runtime as
    # they differ dependent on the environment used
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.38.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = module.tags.common_tags
  }
}

module "tags" {
  source              = "../../modules/tags"
  aws_region          = var.aws_region
  data_classification = "n/a"
  data_type           = "None"
  public_facing       = false
  service_category    = "n/a"
}
