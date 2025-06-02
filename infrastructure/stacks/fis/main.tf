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
  role_arn    = "arn:aws:iam::585768145633:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_Admin_443e66bf1656dcb5"

  stop_condition {
    source = "none"
  }

  action {
    name      = "example-action"
    action_id = "aws:ecs:task-cpu-stress"

    targets {
      key   = "Tasks"
      value = "nhse-bss-euwest2-cicd-ecs"
    }
  }

  # target {
  #   name           = "example task"
  #   resource_type  = "aws:ecs:task"
  #   selection_mode = "COUNT(1)"
  # }
}

