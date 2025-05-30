terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/github-actions.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
  required_providers {
    tls = {
      version = ">= 4.1.0"
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

data "aws_caller_identity" "current" {}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "github_actions" {
  name        = "github-actions-role"
  description = "Role for GitHub Actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:NHSDigital/screening-terraform-bss:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_ec2" {
  name        = "github-actions-global"
  description = "Policy for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DeleteSecurityGroup",
          "ec2:*",
          "vpc:*",
          "rds:*",
          "eks:*",
          "elasticache:*",
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:ListTagsForResource",
          "ecr:SetRepositoryPolicy",
          "ecr:TagResource",
          "ecr:GetRepositoryPolicy",
          "ecs:Describe*",
          "ecs:Delete*",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:SetSubnets",
          "ecs:DeregisterTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:TagResource",
          "ecs:UpdateService",
          "ecs:CreateService",
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "github_actions_ec2" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ec2.arn
}

resource "aws_iam_policy" "github_actions_ecs_iam" {
  name        = "github-actions-ecs-iam"
  description = "Policy for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreatePolicy",
          "iam:TagPolicy"
        ]
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:policy/sample-app-policy"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:role/*",
          "arn:aws:iam::${var.aws_account_id}:role/sample-app-ecs-task-execution-role"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecs_iam" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecs_iam.arn
}

# resource "aws_iam_policy" "github_actions_rds" {
#   name        = "github-actions-rds"
#   description = "Policy for GitHub Actions"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "rds:*",
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
# resource "aws_iam_role_policy_attachment" "github_actions_rds" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.github_actions_rds.arn
# }

# resource "aws_iam_policy" "github_actions_eks" {
#   name        = "github-actions-eks"
#   description = "Policy for GitHub Actions"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "eks:*",
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
# resource "aws_iam_role_policy_attachment" "github_actions_eks" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.github_actions_eks.arn
# }

# resource "aws_iam_policy" "github_actions_elasticache" {
#   name        = "github-actions-elasticache"
#   description = "Policy for GitHub Actions"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticache:*",
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
# resource "aws_iam_role_policy_attachment" "github_actions_elasticache" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.github_actions_elasticache.arn
# }

resource "aws_iam_policy" "github_actions_s3" {
  name        = "github-actions-s3"
  description = "Policy for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "github_actions_s3" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_s3.arn
}

resource "aws_iam_policy" "github_actions_secrets" {
  name        = "github-actions-secrets"
  description = "Policy for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:eu-west-2:${var.aws_account_id}:secret:*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "github_actions_secrets" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_secrets.arn
}

resource "aws_iam_policy" "github_actions_eks_iam" {
  name        = "github-actions-eks-iam"
  description = "Policy for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:AttachRolePolicy",
          "iam:PassRole",
          "iam:GetRole",
        ]
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:role/nhse-bss-euwest2-cicd-eks-cluster",
          "arn:aws:iam::${var.aws_account_id}:role/nhse-bss-euwest2-cicd-eks-node"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "github_actions_eks_iam" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_eks_iam.arn
}

resource "aws_iam_policy" "github_actions_iam" {
  name        = "github-actions-iam"
  description = "Policy for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*",
          "iam:Detach*",
          "iam:Delete*",
          "iam:CreateRole",
          "iam:TagRole"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "github_actions_iam" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_iam.arn
}

resource "aws_iam_policy" "github_actions_logs" {
  name        = "github-actions-logs"
  description = "Policy for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "github_actions_logs" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_logs.arn
}

resource "aws_iam_policy" "github_actions_kms" {
  name        = "github-actions-kms"
  description = "Policy for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:*",
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "github_actions_kms" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_kms.arn
}

