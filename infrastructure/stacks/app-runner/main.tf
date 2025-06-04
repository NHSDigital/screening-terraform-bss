terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/app-runner-test.tfstate"
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

resource "aws_iam_role" "myroles" {
  name = "${var.name_prefix}-app-runner-1234-stma7"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "build.apprunner.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "myrolespolicy" {
  role = aws_iam_role.myroles.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "time_sleep" "waitrolecreate" {
  depends_on = [aws_iam_role.myroles]
  create_duration = "60s"
}

resource "aws_apprunner_service" "my-app-runner" {
  depends_on = [time_sleep.waitrolecreate]
  service_name = "${var.name_prefix}-1234-stma7"
  source_configuration {
    authentication_configuration {
      access_role_arn = "${aws_iam_role.myroles.arn}"
    }
    image_repository {
      image_identifier      = "${var.aws_account_id}.dkr.ecr.eu-west-2.amazonaws.com/nhse-bss-euwest2-cicd:latest"
      image_repository_type = "ECR"
      image_configuration {
        port = 4000
      }
    }
  }
}




