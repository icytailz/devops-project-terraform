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

variable "private_subnets" {
    type = list(string)
    default = []
    description = "A list of private subnets inside the vpc"
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