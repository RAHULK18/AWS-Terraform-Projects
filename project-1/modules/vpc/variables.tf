variable "vpc_name" {
  type = string
  description = "demo-vpc"
}

variable "cidr_block" {
  type = string
  description = "demo-cidr"
}
variable "azs" {
  type = list(string)
  description = "demo-azs"
}
variable "private_subnet_cidrs"{
    type = list(string)
     description = "demo-private-subnet"
}

variable "public_subnet_cidrs"{
    type = list(string)
     description = "demo-public-subnet"
}

variable "enable_nat_gateway" {
  type = bool
  default = true
  description = "Whether to create NAT gateways for private subnets"
  }
variable "single_nat_gateway" {
  type = bool
  default = true
  description = "Whether to use a single NAT gateway or one per AZ"
  }

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources"
}