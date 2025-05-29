resource "aws_ecs_service" "ecs_service" {
  name                = "texas-sample-app-ecs-service"
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
