module "esk-networking" {
  source = "../../modules/network"

  common_tags = var.common_tags

  project_name = var.project_name

  vpc_cidr             = var.vpc_cidr
  vpc_additional_cidrs = var.vpc_additional_cidrs

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  unique_natgw = var.unique_natgw
}
