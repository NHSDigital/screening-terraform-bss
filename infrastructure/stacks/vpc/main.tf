terraform {
  backend "s3" {
    bucket       = "screening-bss-terraform-state"
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
  source      = "github.com/NHSDigital/screening-terraform-modules/terraform_modules/vpc"
  environment = var.environment
  name        = var.name
}
