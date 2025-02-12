output "eks_api_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "API server endpoint"
}
