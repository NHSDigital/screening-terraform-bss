
terraform {
  backend "s3" {
    bucket       = "nhse-bss-cicd-state"
    key          = "terraform-state/ecs.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}




## ecs cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name_prefix}${var.name}"
}

### ecs service
resource "aws_ecs_service" "ecs_service" {
  name                = "${var.name_prefix}${var.name}"
  cluster             = aws_ecs_cluster.ecs_cluster.arn
  task_definition     = aws_ecs_task_definition.task_definition.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 3

  network_configuration {
    subnets          = data.terraform_remote_state.vpc.outputs.private_subnets
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_sg.id, aws_security_group.alb_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "sample-app-container"
    container_port   = var.container_port
  }
  depends_on = [aws_lb_listener.http_listener, aws_lb_listener.https_listener]
}

# task definitions

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "texas-sample-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode(
    [
      {
        "name" : "sample-app-container",
        "image" : "${local.live_mgmt_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/texas-sample-app-repo:7c9ea9472313331fea977bb48ead5532a9e796b8"
        "essential" : true,
        "environment" : [],
        "secrets" : [
          # {
          #   "name" : "INSTANA_ENDPOINT_URL",
          #   "valueFrom" : "${aws_secretsmanager_secret_version.sample_app.arn}:INSTANA_ENDPOINT_URL::"
          # },
          # {
          #   "name" : "INSTANA_AGENT_KEY",
          #   "valueFrom" : "${aws_secretsmanager_secret_version.sample_app.arn}:INSTANA_AGENT_KEY::"
          # }
        ],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : aws_cloudwatch_log_group.sample_app_log_group.name,
            "awslogs-region" : "eu-west-2",
            "awslogs-stream-prefix" : "ecs"
          }
        },
        "networkMode" : "awsvpc",
        "portMappings" : [
          {
            "containerPort" : var.container_port,
            "hostPort" : var.container_port,
          }
        ]
        # "healthCheck" : {
        #   "command" : ["CMD-SHELL", "curl -f http://localhost:80 || exit 1"],
        #   "interval" : 30,
        #   "timeout" : 5,
        #   "startPeriod" : 10,
        #   "retries" : 3
        # }
      }
    ]
  )
}

resource "aws_cloudwatch_log_group" "sample_app_log_group" {
  name              = "/ecs/${var.service_prefix}-sample-app-ecs-fargate"
  retention_in_days = 14
}


