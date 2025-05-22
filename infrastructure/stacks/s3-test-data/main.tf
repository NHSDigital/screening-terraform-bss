terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/s3-test-data.tfstate"
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

module "bucket" {
  source = "./modules/s3"
  bucket_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowFullAccessToS3Bucket",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : [
              "arn:aws:iam::${var.account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_Admin_443e66bf1656dcb5",
              "arn:aws:iam::${var.account_id}:role/github-actions-role"
            ]
          },
          "Action" : "s3:*",
          "Resource" : [
            "arn:aws:s3:::${var.name_prefix}-${var.bucket_name}",
            "arn:aws:s3:::${var.name_prefix}-${var.bucket_name}/*"
          ]
        }
      ]
    }
  )
  name_prefix = var.name_prefix
  environment = var.environment
  name        = var.name
  bucket_name = var.bucket_name
}

