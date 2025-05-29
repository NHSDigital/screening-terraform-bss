terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/ecs.tfstate"
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
      Stack       = "ECS"
    }
  }
}

module "ecs" {
    source = "./modules/ecs
}
