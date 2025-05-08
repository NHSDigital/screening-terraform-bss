terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.25.0"
    }
  }
}

data "aws_secretsmanager_secret_version" "postgres-credentials" {
  secret_id = var.aws_secret_id
}

locals {
  postgres-credentials = jsondecode(data.aws_secretsmanager_secret_version.postgres-credentials.secret_string)
}

data "aws_db_instance" "rds" {
  db_instance_identifier = var.name
}

locals {
  endpoint = data.aws_db_instance.rds.endpoint
  hostname = split(":", local.endpoint)[0]
}


provider "postgresql" {
  host            = local.hostname
  port            = 5432
  database        = "postgres"
  username        = local.postgresql_credentials.username
  password        = local.postgresql_credentials.password
  sslmode         = "require"
  connect_timeout = 15
}

resource "postgresql_database" "my_db" {
  name                   = var.db_name
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
}
