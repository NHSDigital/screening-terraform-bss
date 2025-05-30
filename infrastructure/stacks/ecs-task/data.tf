data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = "${var.name_prefix}${var.cluster_name}"
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

data "aws_iam_role" "ecs_task_execution_role" {
  name = "sample-app-ecs-task-execution-role"
}


