terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/eks.tfstate"
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
      Stack       = "EKS"
    }
  }
}

module "eks" {
  source         = "./modules/eks"
  name           = var.name
  name_prefix    = var.name_prefix
  environment    = var.environment
  aws_account_id = var.aws_account_id
}

