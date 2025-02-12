output "vpc_id" {
  value       = module.esk-networking.vpc_id
  description = "SSM Parameter about vpc id"
}

output "public_subnets" {
  value       = module.esk-networking.public_subnets
  description = "SSM Parameters about public subnets id"
}

output "private_subnets" {
  value       = module.esk-networking.private_subnets
  description = "SSM Parameters about private subnets id"
}

output "natgw_eips" {
  value       = module.esk-networking.natgw_eips
  description = "SSM Parameters about natgw eips id"
}
