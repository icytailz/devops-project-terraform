locals {
  create_vpc = var.create_vpc
}

resource "aws_vpc" "this" {
    count = local.create_vpc ? 1 : 0

    cidr_block = var.cidr
    tags = merge(
      {"Name" = var.name},
      var.tags,
      var.vpc_tags
    )
    
}