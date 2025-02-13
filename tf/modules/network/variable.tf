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

variable "vpc_cidr" {
  type        = string
  description = "The main VPC CIDR"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The VPC must be a valid CIDR address."
  }
}

variable "vpc_additional_cidrs" {
  type        = list(string)
  description = "Additional VPC CIDR's list"
  default     = []
  validation {
    condition = alltrue([
      for cidr in var.vpc_additional_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Additional VPC CIDR must be a valid address."
  }
}

variable "public_subnets" {
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
  description = "The public subnet CIDR"
  validation {
    condition = length(var.public_subnets) > 0 && alltrue([
      for subnet in var.public_subnets : can(cidrhost(subnet.cidr, 0))
    ])
    error_message = "Needs at least one public subnet and it must has a valid CIDR address."
  }
}

variable "private_subnets" {
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
  description = "The private subnet CIDR"
  validation {
    condition = length(var.private_subnets) > 0 && alltrue([
      for subnet in var.private_subnets : can(cidrhost(subnet.cidr, 0))
    ])
    error_message = "Needs at least one private subnet and it must has a valid CIDR address."
  }
}

# This is a point of failure
# Saving money using one nat gateway
variable "unique_natgw" {
  type        = bool
  description = "Just to reduce costs .. create a single NAT gw for all private subnets"
  default     = false
}
