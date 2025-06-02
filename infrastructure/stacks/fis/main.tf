terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/fis.tfstate"
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
      Stack       = "FIS"
    }
  }
}

resource "aws_fis_experiment_template" "example" {
  description = "example"
  role_arn    = "arn:aws:iam::${var.aws_account_id}:role/github-actions-role"

  stop_condition {
    source = "none"
  }

  action {
    name      = "example-action"
    action_id = "aws:ecs:task-cpu-stress"

    target {
      key   = "Tasks"
      value = "ecs-task"
    }

    parameter {
      key   = "duration"
      value = "PT10M"
    }
  }

  target {
    name           = "ecs-task"
    resource_type  = "aws:ecs:task"
    selection_mode = "COUNT(1)"

    resource_tag {
      key   = "test"
      value = "fis"
    }

  }
}

