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
          {
            "name" : "INSTANA_ENDPOINT_URL",
            "valueFrom" : "${aws_secretsmanager_secret_version.sample_app.arn}:INSTANA_ENDPOINT_URL::"
          },
          {
            "name" : "INSTANA_AGENT_KEY",
            "valueFrom" : "${aws_secretsmanager_secret_version.sample_app.arn}:INSTANA_AGENT_KEY::"
          }
        ],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : aws_cloudwatch_log_group.sample_app_log_group.name,
            "awslogs-region" : "eu-west-2",
            "awslogs-stream-prefix" : "ecs"
          }
        },

        #  "logConfiguration": {
        #     "logDriver": "splunk",
        #     "options": {
        #        "splunk-url": "https://texas-0001.inputs.splunk.aws.digital.nhs.uk:8088",
        #        "tag": "texas-sample-app"
        #     },
        #     "secretOptions": [{
        #        "name": "splunk-token",
        #        "valueFrom": "arn:aws:secretsmanager:eu-west-2:235828175016:secret:texas_splunk_hec_tokens-PQGAPP:texas_cw_logs_test_hec::"
        #     }]

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

