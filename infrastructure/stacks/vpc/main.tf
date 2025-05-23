terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/vpc.tfstate"
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
      Stack       = "vpc"
    }
  }
}

module "vpc" {
  source      = "./modules/"
  environment = var.environment
  name        = var.name
  name_prefix = var.name_prefix
}

