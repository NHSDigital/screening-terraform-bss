# ------------------------------------------------------------------------------
# Security Group for ECS app
# ------------------------------------------------------------------------------
resource "aws_security_group" "ecs_sg" {
  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  name                   = "sample-app-sg-ecs"
  description            = "Security group for ECS app"
  revoke_rules_on_delete = true
}
# ------------------------------------------------------------------------------
# ECS app Security Group Rules - INBOUND
# ------------------------------------------------------------------------------
resource "aws_security_group_rule" "ecs_alb_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  description              = "Allow inbound traffic from ALB"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}
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
resource "aws_security_group" "alb_sg" {
  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  name                   = "sample-app-sg-alb"
  description            = "Security group for ALB"
  revoke_rules_on_delete = true
}
# ------------------------------------------------------------------------------
# Alb Security Group Rules - INBOUND
# ------------------------------------------------------------------------------
resource "aws_security_group_rule" "alb_http_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  description              = "Allow http inbound traffic from VPN"
  source_security_group_id = data.terraform_remote_state.security-groups.outputs.vpn_main_sg_id
  security_group_id        = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_https_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "TCP"
  description              = "Allow https inbound traffic from VPN"
  source_security_group_id = data.terraform_remote_state.security-groups.outputs.vpn_main_sg_id
  security_group_id        = aws_security_group.alb_sg.id
}

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
resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow outbound traffic from alb"
  security_group_id = aws_security_group.alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
