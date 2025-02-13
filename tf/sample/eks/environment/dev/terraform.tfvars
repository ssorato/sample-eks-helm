common_tags = {
  created_by = "terraform-sample-eks-flask"
  sandbox    = "eks-flask"
}

project_name = "eks-flask"
region       = "us-east-1"

ssm_vpc = "/eks-network/vpc/id"
ssm_public_subnets = [
  "/eks-network/subnets/private/us-east-1a/eks-flask-private-1a",
  "/eks-network/subnets/private/us-east-1b/eks-flask-private-1b",
  "/eks-network/subnets/private/us-east-1c/eks-flask-private-1c"
]
ssm_private_subnets = [
  "/eks-network/subnets/private/us-east-1a/eks-flask-private-1a",
  "/eks-network/subnets/private/us-east-1b/eks-flask-private-1b",
  "/eks-network/subnets/private/us-east-1c/eks-flask-private-1c"
]
ssm_pod_subnets = [
  "/eks-network/subnets/private/us-east-1a/eks-flask-pods-1a",
  "/eks-network/subnets/private/us-east-1b/eks-flask-pods-1b",
  "/eks-network/subnets/private/us-east-1c/eks-flask-pods-1c"
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
