locals {
  aws_account_id = jsondecode(data.aws_secretsmanager_secret_version.account_ids.secret_string)[var.simple_env]
}

resource "github_repository_environment" "repo_environment" {
  repository  = data.github_repository.repo.name
  environment = var.simple_env
}

resource "github_actions_environment_secret" "tf_version" {
  repository      = data.github_repository.repo.name
  environment     = github_repository_environment.repo_environment.environment
  secret_name     = "AWS_ACCOUNT"
  plaintext_value = local.aws_account_id
}

resource "github_actions_environment_variable" "tf_version" {
  repository    = data.github_repository.repo.name
  environment   = github_repository_environment.repo_environment.environment
  variable_name = "TF_VERSION"
  value         = var.terraform_version
}

# resource "github_actions_environment_variable" "terraform_stack" {
#   #for_each      = var.terraform_deploy_stacks
#   repository    = data.github_repository.repo.name
#   environment   = github_repository_environment.repo_environment.environment
#   variable_name = "cicd"
#   value         = join(", ", [for s in setsubtract(each.value, var.terraform_exclude_stacks[each.key]) : format("'%s'", s)])
# }
