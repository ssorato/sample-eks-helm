common_tags = {
  created_by = "terraform-sample-eks-helm"
  sandbox    = "eks-helm"
}

project_name = "eks-helm"
region       = "us-east-1"

ssm_vpc = "/eks-network/vpc/id"
ssm_private_subnets = [
  "/eks-network/subnets/private/us-east-1a/eks-helm-private-1a",
  "/eks-network/subnets/private/us-east-1b/eks-helm-private-1b",
  "/eks-network/subnets/private/us-east-1c/eks-helm-private-1c"
]
ssm_pod_subnets = [
  "/eks-network/subnets/private/us-east-1a/eks-helm-pods-1a",
  "/eks-network/subnets/private/us-east-1b/eks-helm-pods-1b",
  "/eks-network/subnets/private/us-east-1c/eks-helm-pods-1c"
]
ssm_natgw_eips = [
  "/eks-network/subnets/public/us-east-1a/natgw-eip"
]

k8s_version = "1.32"

addon_cni_version       = "v1.19.2-eksbuild.1"
addon_coredns_version   = "v1.11.4-eksbuild.2"
addon_kubeproxy_version = "v1.32.0-eksbuild.2"

auto_scale_options = {
  min     = 2
  max     = 5
  desired = 4 # CoreDNS requires 3 replicas
}

nodes_instance_sizes = [
  "t3a.micro" # Max 4 PODs per node
]

ecr_repos_name = [
  "hello", # docker image
  "myapp" # helm chart
]
