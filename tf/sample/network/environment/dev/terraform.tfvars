common_tags = {
  created_by = "terraform-sample-eks-flask"
  sandbox    = "eks-flask"
}

project_name = "eks-network"
region       = "us-east-1"

vpc_cidr = "10.0.0.0/16"

vpc_additional_cidrs = [
  "100.64.0.0/16" # Permitted associations with VPC main IP address range
]

public_subnets = [
  {
    name              = "eks-flask-public-1a"
    cidr              = "10.0.48.0/24"
    availability_zone = "us-east-1a"
  },
  {
    name              = "eks-flask-public-1b"
    cidr              = "10.0.49.0/24"
    availability_zone = "us-east-1b"
  },
  {
    name              = "eks-flask-public-1c"
    cidr              = "10.0.50.0/24"
    availability_zone = "us-east-1c"
  }
]

private_subnets = [
  {
    name              = "eks-flask-private-1a"
    cidr              = "10.0.0.0/20"
    availability_zone = "us-east-1a"
  },
  {
    name              = "eks-flask-private-1b"
    cidr              = "10.0.16.0/20"
    availability_zone = "us-east-1b"
  },
  {
    name              = "eks-flask-private-1c"
    cidr              = "10.0.32.0/20"
    availability_zone = "us-east-1c"
  },
  {
    name              = "eks-flask-pods-1a"
    cidr              = "100.64.0.0/18"
    availability_zone = "us-east-1a"
  },
  {
    name              = "eks-flask-pods-1b"
    cidr              = "100.64.64.0/18"
    availability_zone = "us-east-1b"
  },
  {
    name              = "eks-flask-pods-1c"
    cidr              = "100.64.128.0/18"
    availability_zone = "us-east-1c"
  }
]

unique_natgw = true