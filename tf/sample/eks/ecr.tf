resource "aws_ecr_repository" "main" {
  count                = length(var.ecr_repos_name)
  name                 = var.ecr_repos_name[count.index]
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
