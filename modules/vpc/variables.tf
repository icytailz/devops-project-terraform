variable "create_vpc" {
    type = bool
    default = true
    description = "Determine to create vpc or not"
}

variable "public_subnets" {
    type = list(string)
    default = []
    description = "A list of public subnets inside the vpc"
}
variable "public_subnet_names" {
    default = []
    type = list(string)
    description = "Name tag for the public subnet. If empty, name tags are generated"
}
variable "public_subnet_suffix" {
    type = string
    default = "public"
    description = "Suffix to append to public subnets name"
}
variable "public_subnet_tags" {
    type = map(string)
    default = {}
    description = "Additional tags for the public subnets"
}
variable "public_subnet_tags_per_az" {
    type = map(map(string))
    default = {}
    description = "Additional tags for the public subnets where the primary key is the AZ"
}

#Private subnet
variable "private_subnets" {
    type = list(string)
    default = []
    description = "A list of private subnets inside the vpc"
}

variable "private_subnet_tags_per_az" {
    type = map(map(string))
    default = {}
    description = "Additional tags for the private subnets where the primary key is the AZ"
}

variable "private_subnet_names" {
    type = list(string)
    default = []
    description = "Explicit values to use in the name tag on private subnets. If empty, Name tags are generated"
}

variable "private_subnet_suffix" {
   type = string
   default =   "private"
   description = "Suffix to append to private subnets name"
}

variable "private_subnet_tags" { 
    type = map(string)
    default = {}
    description = "Additional tags for the private subnets"
}

variable "private_route_table_tags" { 
    type = map(string)
    default = {}
    description = "Additional tags foe the private route tables"
}

variable "create_multiple_public_route_tables" {
    type = bool
    default = false
    description = "Indicates whether to create a separate route table for each subnet"
}

variable "public_route_table_tags" {
    type = map(string)
    default = {}
    description = "Additional tags for the public route tables"
}

variable "create_igw" {
    type = bool
    default = true
    description = "Controls if an internet gateway is created for public subnets and the related routes that connect them"
}
variable "azs" {
    description = "List of availability zones by name or id in the region"
    type = list(string)
    default = []
}
variable "name" {
    type = string
    default = ""
    description = "Name to be used on all the resouces as identifier"
}

variable "cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "(Optional) The IPv4 CIDR block for the VPC"
}

variable "tags" {
    type = map(string)
    default = {}
    description = "A map of tags to add to all resources"
}

variable "vpc_tags" {
    type = map(string)
    default = {}
    description = "Additional tags for the vpc"
}

variable "secondary_cidr_blocks" {
    type = list(string)
    default = []
    description = "Provides a resource to associate additional IPv4 CIDR blocks with a VPC"
}

variable "enable_dns_hostnames" {
    type = bool
    default = true
}

variable "enable_dns_support" {
    type = bool
    default = true
}

#NAT gateway

variable "enable_nat_gateway" {
    type = bool
    default = false
    description = "Should be true if you want to provision NAT gatway for each of your private networks"
}
variable "single_nat_gateway" {
    type = bool
    default = false
    description = "Should be true if you want to provision a single shared NAT gatway across all of your private networks"
}

variable "nat_gateway_destination_cidr_block" {
    type = string
    default = "0.0.0.0/0"
    description = "Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route"
}

variable "reuse_nat_ips" {
    type = bool
    default = false
    description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
}

variable "one_nat_gateway_per_az" {
    type = bool
    default = false
    description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`"
}
variable "external_nat_ip_ids" {
    type = list(string)
    default = []
    description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
}
variable "nat_eip_tags" {
    type = map(string)
    default = {}
    description = "Additional tags for the NAT EIP"
}

variable "nat_gateway_tags" {
    type = map(string)
    default = {}
    description = "Additional tags for the NAT gateways"
}

variable "external_nat_ips" {
    type = list(string)
    default = []
    description = "List of EIPs to be used for `nat_public_ips` output (used in combination with reuse_nat_ips and external_nat_ip_ids)"
}

#Internet gateway
variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type        = map(string)
  default     = {}
}