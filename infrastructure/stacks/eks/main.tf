terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
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
      Stack       = "EKS"
    }
  }
}

locals {
  cluster_name = "${var.name_prefix}${var.name}"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.name_prefix}${var.vpc_name}"]
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

data "aws_subnet" "private_subnets" {
  for_each = toset(data.aws_subnets.private_subnets.ids)
  id       = each.value
}

data "aws_subnet" "public_subnets" {
  for_each = toset(data.aws_subnets.public_subnets.ids)
  id       = each.value
}

# module "vpc_eks" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.18.1"
#   name = local.cluster_name
#   cidr = "10.0.0.0/24"
#   azs             = [for subnet in data.aws_subnet.private_subnets : subnet.availability_zone]
#   private_subnets = [for subnet in data.aws_subnet.private_subnets : subnet.cidr_block]
#   public_subnets  = [for subnet in data.aws_subnet.public_subnets : subnet.cidr_block]
#   # azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
#   # private_subnets = [for subnet in data.aws_subnet.private_subnets : subnet.cidrsubnet]
#   # private_subnets = data.aws_subnets.private_subnets.ids
#   # private_subnets = [data.aws_subnets.private_subnets[0].cidr, data.aws_subnets.private_subnets[1].cidr]
#   # public_subnets = data.aws_subnets.public_subnets.ids
#   # public_subnets = [for subnet in data.aws_subnet.public_subnets : subnet.cidrsubnet]
#   enable_nat_gateway     = true
#   single_nat_gateway     = true
#   one_nat_gateway_per_az = false
#   enable_vpn_gateway = true
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#   propagate_private_route_tables_vgw = true
#   propagate_public_route_tables_vgw  = true
#   private_subnet_tags = {
#     "kubernetes.io/role/internal-elb" = "1",
#     "mapPublicIpOnLaunch"             = "FALSE"
#     "karpenter.sh/discovery"          = local.cluster_name
#     "kubernetes.io/role/cni"          = "1"
#   }
#   public_subnet_tags = {
#     "kubernetes.io/role/elb" = "1",
#     "mapPublicIpOnLaunch"    = "TRUE"
#   }
#   tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#   }
# }

resource "aws_eks_cluster" "cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = "1.32"

  vpc_config {
    subnet_ids              = data.aws_subnets.public_subnets.ids
    security_group_ids      = []
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  bootstrap_self_managed_addons = false

  zonal_shift_config {
    enabled = true
  }

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose", "system"]
    node_role_arn = aws_iam_role.node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }
}

resource "aws_iam_role" "cluster" {
  name = "${local.cluster_name}-cluster"

  assume_role_policy = data.aws_iam_policy_document.cluster_role_assume_role_policy.json
}

resource "aws_iam_role_policy_attachments_exclusive" "cluster" {
  role_name = aws_iam_role.cluster.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]
}

data "aws_iam_policy_document" "cluster_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name = "${local.cluster_name}-node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = local.cluster_name
  principal_arn = "arn:aws:iam::${var.aws_account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_Admin_443e66bf1656dcb5"
}
resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = local.cluster_name
  principal_arn = "arn:aws:iam::${var.aws_account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_Admin_443e66bf1656dcb5"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "user" {
  cluster_name  = local.cluster_name
  principal_arn = "arn:aws:iam::${var.aws_account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_PowerUser_daddc08250323b7f"
}
resource "aws_eks_access_policy_association" "user_cluster" {
  cluster_name  = local.cluster_name
  principal_arn = "arn:aws:iam::${var.aws_account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_PowerUser_daddc08250323b7f"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  access_scope {
    type = "cluster"
  }
}
resource "aws_eks_access_policy_association" "user_namespace" {
  cluster_name  = local.cluster_name
  principal_arn = "arn:aws:iam::${var.aws_account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_PowerUser_daddc08250323b7f"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  access_scope {
    type       = "namespace"
    namespaces = ["default", "ancl11", "stma7"]
  }
}

