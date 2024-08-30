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
variable "private_subnets" {
    type = list(string)
    default = []
    description = "A list of private subnets inside the vpc"
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
    type = number
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