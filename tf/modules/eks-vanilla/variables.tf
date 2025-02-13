variable "common_tags" {
  type        = map(string)
  description = "Common tags"
}

variable "project_name" {
  type        = string
  description = "The resource name sufix"
  validation {
    condition = length(var.project_name) > 0
    error_message = "Project name cannot be an empty string."
  }
}

variable "region" {
  type        = string
  description = "The AWS region"
  validation {
    condition = length(var.region) > 0
    error_message = "Region name cannot be an empty string."
  }
}

variable "ssm_vpc" {
  type        = string
  description = "The main VPC from AWS SSM parameters"
}

variable "ssm_private_subnets" {
  type        = list(string)
  description = "Private subnets from AWS SSM parameters"
}

variable "ssm_pod_subnets" {
  type        = list(string)
  description = "PODs subnets from AWS SSM parameters"
}

variable "ssm_natgw_eips" {
  type        = list(string)
  description = "NAT gw EIP from AWS SSM parameters"
}

variable "k8s_version" {
  type        = string
  description = "The kubernetes version"
}

variable "api_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint when enabled"
  default     = ["0.0.0.0/0"]
  validation {
    condition = alltrue([
      for cidr in var.api_public_access_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "CIDR must be a valid address."
  }
}

variable "eks_oidc_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable "auto_scale_options" {
  type = object({
    min     = number
    max     = number
    desired = number
  })
  description = "Cluster autoscaling configurations"
}

variable "nodes_instance_sizes" {
  type        = list(string)
  description = "List of instance types associated with the EKS Node Group"
}

variable "addon_cni_version" {
  type        = string
  description = "VPC CNI addon version"
  default     = "v1.18.3-eksbuild.2"
}

variable "addon_coredns_version" {
  type        = string
  description = "CoreDNS addon version"
  default     = "v1.11.3-eksbuild.1"
}

variable "addon_kubeproxy_version" {
  type        = string
  description = "Kube-Proxy addon version"
  default     = "v1.31.2-eksbuild.3"
}

variable "metrics_server_version" {
  type        = string
  description = "The metric server version"
  default     = "7.2.16"
}

variable "route53" {
  type = object({
    dns_name    = string
    hosted_zone = string
  })
  description = "Route53 dns name and hosted zone"
}

variable "node_labels" {
  type        = map(string)
  description = "Additional node labels"
  default     = {}
}
