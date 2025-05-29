resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name_prefix}${var.name}"
}
