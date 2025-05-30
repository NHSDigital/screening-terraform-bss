data "aws_secretsmanager_secret" "account_ids" {
  name = "aws_account_ids"
}

data "aws_secretsmanager_secret_version" "account_ids" {
  secret_id = data.aws_secretsmanager_secret.account_ids.id
}

locals {
  aws_account_ids = jsondecode(data.aws_secretsmanager_secret_version.account_ids.secret_string)
}

data "aws_iam_policy_document" "sample_app_repo" {
  statement {
    sid    = "AllowJenkinsRolesBuildAndPush"
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
        "arn:aws:iam::${local.aws_account_ids["test-k8s"]}:root",
        "arn:aws:iam::${local.aws_account_ids["test-mgmt"]}:root",
        "arn:aws:iam::${local.aws_account_ids["dev-k8s"]}:root",
        "arn:aws:iam::${local.aws_account_ids["dev-mgmt"]}:root",
        "arn:aws:iam::${local.aws_account_ids["live-mgmt"]}:root",
        "arn:aws:iam::${local.aws_account_ids["live-nonprod"]}:root",
        "arn:aws:iam::${local.aws_account_ids["live-prod"]}:root"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::*:role/texas-github",
        "arn:aws:iam::*:role/AWSReservedSSO_Texas-Admin_*"
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
        "arn:aws:iam::${local.aws_account_ids["test-k8s"]}:root",
        "arn:aws:iam::${local.aws_account_ids["test-mgmt"]}:root",
        "arn:aws:iam::${local.aws_account_ids["dev-k8s"]}:root",
        "arn:aws:iam::${local.aws_account_ids["dev-mgmt"]}:root",
        "arn:aws:iam::${local.aws_account_ids["live-mgmt"]}:root",
        "arn:aws:iam::${local.aws_account_ids["live-nonprod"]}:root",
        "arn:aws:iam::${local.aws_account_ids["live-prod"]}:root"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::*:role/texas-ecs-task-execution-role"
      ]
    }
  }
}