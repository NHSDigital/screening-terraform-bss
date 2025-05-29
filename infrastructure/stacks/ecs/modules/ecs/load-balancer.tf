resource "aws_alb" "application_load_balancer" {
  name = "sample-app-alb"
  #internal           = false

  # behind Texas VPN so internal load balancer
  internal = true

  load_balancer_type = "application"
  #subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  subnets = [
    data.terraform_remote_state.vpc.outputs.private_subnets[0],
    data.terraform_remote_state.vpc.outputs.private_subnets[1],
    data.terraform_remote_state.vpc.outputs.private_subnets[2]
  ]

  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "target_group" {
  name        = "sample-app-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
    #port                = "traffic-port"
    port                = 4000
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
  }
}

#Defines an HTTP Listener for the ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

#Defines an HTTPs Listener for the ALB
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"

  # TODO - use an output from the certificate stack rather than hard coding the cert ARN
  certificate_arn = "arn:aws:acm:eu-west-2:${local.local_account_id}:certificate/f880396f-8408-48d5-9680-c74a37297be0"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

