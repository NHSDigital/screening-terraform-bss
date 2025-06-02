resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "sample-app-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role is the role assumed by the running ECS task
# resource "aws_iam_role" "ecs_task_role" {
#   name               = "sample-app-ecs-task-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
# }


# Allow access to Instana secrets for Fargate monitoring
# data "aws_iam_policy_document" "ecs_task_role" {
#   statement {
#     sid    = "AllowSecrets"
#     effect = "Allow"
#     actions = [
#       "secretsmanager:GetSecretValue"
#     ]
#     resources = [
#       # aws_secretsmanager_secret_version.sample_app.arn
#     ]
#   }
# }

# resource "aws_iam_policy" "ecs_task_policy" {
#   name   = "sample-app-policy"
#   policy = data.aws_iam_policy_document.ecs_task_role.json
# }

# resource "aws_iam_role_policy_attachment" "task_role_attachment" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = aws_iam_policy.ecs_task_policy.arn
# }
