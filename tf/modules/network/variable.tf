variable "common_tags" {
  type        = map(string)
  description = "Common tags"
}

variable "project_name" {
  type        = string
  description = "The resource name sufix"
}

variable "vpc_cidr" {
  type        = string
  description = "The main VPC CIDR"
}

variable "vpc_additional_cidrs" {
  type        = list(string)
  description = "Additional VPC CIDR's list"
  default     = []
}

variable "public_subnets" {
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
  description = "The public subnet CIDR"
}

variable "private_subnets" {
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
  description = "The private subnet CIDR"
}

# This is a point of failure
# Saving money using one nat gateway
variable "unique_natgw" {
  type        = bool
  description = "Just to reduce costs .. create a single NAT gw for all private subnets"
  default     = false
}
