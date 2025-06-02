## ecs cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name_prefix}${var.name}"
}

### ecs service
# resource "aws_ecs_service" "ecs_service" {
#   name                = "${var.name_prefix}${var.name}"
#   cluster             = aws_ecs_cluster.ecs_cluster.arn
#   task_definition     = aws_ecs_task_definition.task_definition.arn
#   launch_type         = "FARGATE"
#   scheduling_strategy = "REPLICA"
#   desired_count       = 3

#   network_configuration {
#     subnets          = data.aws_subnets.private_subnets.ids
#     assign_public_ip = false
#     security_groups  = [aws_security_group.ecs_sg.id, aws_security_group.alb_sg.id]
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.target_group.arn
#     container_name   = "sample-app-container"
#     container_port   = var.container_port
#   }
#   depends_on = [aws_lb_listener.http_listener]
# }

# task definitions

# resource "aws_ecs_task_definition" "task_definition" {
#   family                   = "texas-sample-app"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = "256"
#   memory                   = "512"
#   execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#   task_role_arn            = aws_iam_role.ecs_task_role.arn
#   container_definitions = jsonencode(
#     [
#       {
#         "name" : "sample-app-container",
#         "image" : "${var.aws_account_id}.dkr.ecr.eu-west-2.amazonaws.com/nhse-bss-euwest2-cicd:latest"
#         "essential" : true,
#         "environment" : [],
#         "secrets" : [
#           # {
#           #   "name" : "INSTANA_ENDPOINT_URL",
#           #   "valueFrom" : "${aws_secretsmanager_secret_version.sample_app.arn}:INSTANA_ENDPOINT_URL::"
#           # },
#           # {
#           #   "name" : "INSTANA_AGENT_KEY",
#           #   "valueFrom" : "${aws_secretsmanager_secret_version.sample_app.arn}:INSTANA_AGENT_KEY::"
#           # }
#         ],
#         "logConfiguration" : {
#           "logDriver" : "awslogs",
#           "options" : {
#             "awslogs-group" : aws_cloudwatch_log_group.sample_app_log_group.name,
#             "awslogs-region" : "eu-west-2",
#             "awslogs-stream-prefix" : "ecs"
#           }
#         },
#         "networkMode" : "awsvpc",
#         "portMappings" : [
#           {
#             "containerPort" : var.container_port,
#             "hostPort" : var.container_port,
#           }
#         ]
#         # "healthCheck" : {
#         #   "command" : ["CMD-SHELL", "curl -f http://localhost:80 || exit 1"],
#         #   "interval" : 30,
#         #   "timeout" : 5,
#         #   "startPeriod" : 10,
#         #   "retries" : 3
#         # }
#       }
#     ]
#   )
# }

# resource "aws_cloudwatch_log_group" "sample_app_log_group" {
#   name              = "/ecs/${var.name_prefix}-sample-app-ecs-fargate"
#   retention_in_days = 14
# }


# load balancer

# resource "aws_alb" "application_load_balancer" {
#   name = "sample-app-alb"

#   # behind Texas VPN so internal load balancer
#   internal = false

#   load_balancer_type = "application"
#   subnets            = data.aws_subnets.public_subnets.ids

#   security_groups = [aws_security_group.alb_sg.id]
# }

# resource "aws_lb_target_group" "target_group" {
#   name        = "sample-app-tg"
#   port        = var.container_port
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = data.aws_vpc.vpc.id
#   health_check {
#     path     = "/"
#     protocol = "HTTP"
#     matcher  = "200"
#     #port                = "traffic-port"
#     port                = 4000
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 10
#     interval            = 30
#   }
# }

#Defines an HTTP Listener for the ALB
# resource "aws_lb_listener" "http_listener" {
#   load_balancer_arn = aws_alb.application_load_balancer.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group.arn
#   }
# }

#Defines an HTTPs Listener for the ALB
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_alb.application_load_balancer.arn
#   port              = "443"
#   protocol          = "HTTPS"

#   # TODO - use an output from the certificate stack rather than hard coding the cert ARN
#   certificate_arn = "arn:aws:acm:eu-west-2:${local.local_account_id}:certificate/f880396f-8408-48d5-9680-c74a37297be0"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group.arn
#   }
# }

# security groups

# ------------------------------------------------------------------------------
# Security Group for ECS app
# ------------------------------------------------------------------------------
resource "aws_security_group" "ecs_sg" {
  vpc_id                 = data.aws_vpc.vpc.id
  name                   = "sample-app-sg-ecs"
  description            = "Security group for ECS app"
  revoke_rules_on_delete = true
}
# ------------------------------------------------------------------------------
# ECS app Security Group Rules - INBOUND
# ------------------------------------------------------------------------------
# resource "aws_security_group_rule" "ecs_alb_ingress" {
#   type                     = "ingress"
#   from_port                = 0
#   to_port                  = 0
#   protocol                 = "-1"
#   description              = "Allow inbound traffic from ALB"
#   security_group_id        = aws_security_group.ecs_sg.id
#   source_security_group_id = aws_security_group.alb_sg.id
# }
# ------------------------------------------------------------------------------
# ECS app Security Group Rules - OUTBOUND
# ------------------------------------------------------------------------------
resource "aws_security_group_rule" "ecs_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow outbound traffic from ECS"
  security_group_id = aws_security_group.ecs_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# ------------------------------------------------------------------------------
# Security Group for alb
# ------------------------------------------------------------------------------
# resource "aws_security_group" "alb_sg" {
#   vpc_id                 = data.aws_vpc.vpc.id
#   name                   = "sample-app-sg-alb"
#   description            = "Security group for ALB"
#   revoke_rules_on_delete = true
# }
# ------------------------------------------------------------------------------
# Alb Security Group Rules - INBOUND
# ------------------------------------------------------------------------------
# resource "aws_security_group_rule" "alb_http_ingress" {
#   type                     = "ingress"
#   from_port                = 80
#   to_port                  = 80
#   protocol                 = "TCP"
#   description              = "Allow http inbound traffic from VPN"
#   source_security_group_id = data.terraform_remote_state.security-groups.outputs.vpn_main_sg_id
#   security_group_id        = aws_security_group.alb_sg.id
# }

# resource "aws_security_group_rule" "alb_https_ingress" {
#   type                     = "ingress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "TCP"
#   description              = "Allow https inbound traffic from VPN"
#   source_security_group_id = data.terraform_remote_state.security-groups.outputs.vpn_main_sg_id
#   security_group_id        = aws_security_group.alb_sg.id
# }

# resource "aws_security_group_rule" "alb_https_ingress" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "TCP"
#   description       = "Allow https inbound traffic from internet"
#   security_group_id = aws_security_group.alb_sg.id
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "alb_https_ingress" {
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "TCP"
#   description       = "Allow https inbound traffic from internet"
#   security_group_id = aws_security_group.alb_sg.id
#   cidr_blocks       = ["0.0.0.0/0"]
# }

# ------------------------------------------------------------------------------
# Alb Security Group Rules - OUTBOUND
# ------------------------------------------------------------------------------
# resource "aws_security_group_rule" "alb_egress" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   description       = "Allow outbound traffic from alb"
#   security_group_id = aws_security_group.alb_sg.id
#   cidr_blocks       = ["0.0.0.0/0"]
# }
