output "eks_api_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "API server endpoint"
}

output "k8s_token" {
  value = data.aws_eks_cluster_auth.default.token
}

output "cluster_ca_certificate" {
  value = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
}