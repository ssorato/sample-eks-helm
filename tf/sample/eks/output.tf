output "eks_api_endpoint" {
  value       = module.esk.eks_api_endpoint
  description = "API server endpoint"
}

output "ecr_repos" {
  value = aws_ecr_repository.main[*].id
  description = "The ECR repositories id"
}
