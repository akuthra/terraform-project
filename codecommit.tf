resource "aws_codecommit_repository" "acs_repository" {
  repository_name = var.repository_name
  description     = "ACS Repository"
}

