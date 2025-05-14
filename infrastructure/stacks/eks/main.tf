terraform {
  backend "s3" {
    bucket       = "screening-bss-terraform-state"
    key          = "terraform-state/eks.tfstate"
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

# This gets the aws account details so we can fetch the account ID
data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-${var.name}"]
  }
}

# Get public subnets
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }
  filter {
    name   = "tag:kubernetes.io/role/elb"
    values = ["1"]
  }
}
# Get private subnets
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }
  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.environment
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  cluster_addons = {
    # coredns = {
    #   most_recent = true
    # }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = data.aws_vpc.vpc.id
  subnet_ids               = data.aws_subnets.private_subnets.ids
  control_plane_subnet_ids = data.aws_subnets.public_subnets.ids

  # Fargate Profile
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
      tags = {
        Environment = var.environment
      }
    }
    kube-system = {
      name = "kube-system"
      selectors = [
        {
          namespace = "kube-system"
        }
      ]
      tags = {
        Environment = var.environment
      }
    }
  }

  # Cluster access entry
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${var.account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_Admin_443e66bf1656dcb5"
}
resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${var.account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_Admin_443e66bf1656dcb5"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  access_scope {
    type = "cluster"
  }
  # access_scope {
  #   type       = "namespace"
  #   namespaces = ["default", "ancl11", "stma7", "kube-system"]
  # }
}

resource "aws_eks_access_entry" "user" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${var.account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_PowerUser_daddc08250323b7f"
}
resource "aws_eks_access_policy_association" "user" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${var.account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_PowerUser_daddc08250323b7f"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  access_scope {
    type = "cluster"
  }
}
resource "aws_eks_access_policy_association" "user" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${var.account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_PowerUser_daddc08250323b7f"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  access_scope {
    type       = "namespace"
    namespaces = ["default", "ancl11", "stma7"]
  }
}

