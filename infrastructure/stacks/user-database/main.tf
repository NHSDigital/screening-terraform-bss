terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.25.0"
    }
  }
}

module "database" {
  source        = "./modules/rds-database"
  name          = var.name
  environment   = var.environment
  aws_secret_id = "postgres-credentials"
  db_name       = var.db_name
}

