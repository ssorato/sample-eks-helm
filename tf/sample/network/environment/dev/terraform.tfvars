common_tags = {
  created_by = "terraform-sample-eks-helm"
  sandbox    = "eks-helm"
}

project_name = "eks-network"
region       = "us-east-1"

vpc_cidr = "10.0.0.0/16"

vpc_additional_cidrs = [
  "100.64.0.0/16" # Permitted associations with VPC main IP address range
]

public_subnets = [
  {
    name              = "eks-helm-public-1a"
    cidr              = "10.0.48.0/24"
    availability_zone = "us-east-1a"
  },
  {
    name              = "eks-helm-public-1b"
    cidr              = "10.0.49.0/24"
    availability_zone = "us-east-1b"
  },
  {
    name              = "eks-helm-public-1c"
    cidr              = "10.0.50.0/24"
    availability_zone = "us-east-1c"
  }
]

private_subnets = [
  {
    name              = "eks-helm-private-1a"
    cidr              = "10.0.0.0/20"
    availability_zone = "us-east-1a"
  },
  {
    name              = "eks-helm-private-1b"
    cidr              = "10.0.16.0/20"
    availability_zone = "us-east-1b"
  },
  {
    name              = "eks-helm-private-1c"
    cidr              = "10.0.32.0/20"
    availability_zone = "us-east-1c"
  },
  {
    name              = "eks-helm-pods-1a"
    cidr              = "100.64.0.0/18"
    availability_zone = "us-east-1a"
  },
  {
    name              = "eks-helm-pods-1b"
    cidr              = "100.64.64.0/18"
    availability_zone = "us-east-1b"
  },
  {
    name              = "eks-helm-pods-1c"
    cidr              = "100.64.128.0/18"
    availability_zone = "us-east-1c"
  }
]

unique_natgw = true