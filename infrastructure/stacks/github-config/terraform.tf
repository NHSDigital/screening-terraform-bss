terraform {
  backend "s3" {
    encrypt = true
    # Other parameters are defined at runtime as
    # they differ dependent on the environment used
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "NHSDigital"
}
