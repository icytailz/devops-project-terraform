variable "create_vpc" {
    type = bool
    default = true
    description = "Determine to create vpc or not"
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