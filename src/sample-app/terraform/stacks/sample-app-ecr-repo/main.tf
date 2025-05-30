resource "aws_ecr_repository" "image_repository" {
  name = "${var.service_prefix}-sample-app-repo"
}

resource "aws_ecr_repository_policy" "ecr_repo_policy" {
  repository = aws_ecr_repository.image_repository.name
  policy     = data.aws_iam_policy_document.sample_app_repo.json
}

