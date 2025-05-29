terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/ecr.tfstate"
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
      Stack       = "ECR"
    }
  }
}

resource "aws_ecr_repository" "image_repository" {
  name = var.name_prefix
}

resource "aws_ecr_repository_policy" "ecr_repo_policy" {
  repository = aws_ecr_repository.image_repository.name
  policy     = data.aws_iam_policy_document.ecr_repo_policy_document.json
}

data "aws_iam_policy_document" "ecr_repo_policy_document" {
  statement {
    sid    = "AllowGitHubBuildAndPush"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${var.aws_account_id}:role/github-actions-role",
        "arn:aws:iam::${var.aws_account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_Admin_443e66bf1656dcb5"
      ]
    }
  }
  statement {
    sid    = "AllowAllPullImage"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${var.aws_account_id}:role/sample-app-ecs-task-execution-role"
      ]
    }
  }
}
