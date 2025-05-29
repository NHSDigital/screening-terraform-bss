resource "aws_secretsmanager_secret" "sample_app" {
  name = "${var.service_prefix}-sample-app2"
}

resource "aws_secretsmanager_secret_version" "sample_app" {
  secret_id = aws_secretsmanager_secret.sample_app.id

  secret_string = "[]"

  lifecycle {
    ignore_changes = [secret_string]
  }
}