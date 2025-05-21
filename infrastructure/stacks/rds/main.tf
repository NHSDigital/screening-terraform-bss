terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/rds.tfstate"
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
    }
  }
}

module "rds" {
  source              = "./modules/rds-instance"
  name                = var.name
  environment         = var.environment
  aws_secret_id       = "postgres-credentials"
  rds_instance_class  = "db.r7g.large"
  rds_engine_version  = "17"
  publicly_accessible = true
  ingress_cidr        = var.ingress_cidr
  skip_final_snapshot = true
}

