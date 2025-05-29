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
