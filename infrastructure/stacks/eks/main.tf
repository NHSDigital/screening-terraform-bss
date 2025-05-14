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

resource "null_resource" "kubectl" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = "aws eks --region eu-west-2 update-kubeconfig --name ${var.environment}"
  }
}
