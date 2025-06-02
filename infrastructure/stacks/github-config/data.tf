data "github_repository" "repo" {
  full_name = "NHSDigital/screening-terraform-bss"
}

data "aws_secretsmanager_secret" "account_ids" {
  name = "aws_account_ids"
}

data "aws_secretsmanager_secret_version" "account_ids" {
  secret_id = data.aws_secretsmanager_secret.account_ids.id
}
