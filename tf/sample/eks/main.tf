data "http" "myip" {
  url = "http://ifconfig.me"
}

module "esk" {
  source = "../../modules/eks-vanilla"

  common_tags = var.common_tags

  project_name = var.project_name

  region = var.region

  ssm_vpc             = var.ssm_vpc
  ssm_private_subnets = var.ssm_private_subnets
  ssm_pod_subnets     = var.ssm_pod_subnets
  ssm_natgw_eips      = var.ssm_natgw_eips

  k8s_version             = var.k8s_version
  addon_cni_version       = var.addon_cni_version
  addon_coredns_version   = var.addon_coredns_version
  addon_kubeproxy_version = var.addon_kubeproxy_version
  api_public_access_cidrs = ["${chomp(data.http.myip.response_body)}/32"]

  auto_scale_options   = var.auto_scale_options
  nodes_instance_sizes = var.nodes_instance_sizes

  route53 = var.route53
}
