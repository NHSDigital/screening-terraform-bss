terraform {
  backend "s3" {
    bucket       = "screening-bss-terraform-state"
    key          = "terraform-state/user-database.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.25.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "True"
    }
  }
}

module "database" {
  source        = "./modules/rds-database"
  name          = var.name
  environment   = var.environment
  aws_secret_id = var.aws_secret_id
  db_name       = var.db_name
}

