locals {
  create_vpc = var.create_vpc

  len_public_subnets = length(var.public_subnets)
  len_private_subnets = length(var.private_subnets)

  #Use local.vpc_id to give a hint to Terraform that subnets should be deleted before secondary CIDR block can be free.
  vpc_id = try(aws_vpc_ipv4_cidr_block_association.this[0].vpc_id, aws_vpc.this[0].id, "")
}

resource "aws_vpc" "this" {
    count = local.create_vpc ? 1 : 0

    cidr_block = var.cidr
    
    enable_dns_hostnames = var.enable_dns_hostnames
    enable_dns_support = var.enable_dns_support
    tags = merge(
      {"Name" = var.name},
      var.tags,
      var.vpc_tags
    )
    
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = local.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0
  vpc_id = aws_vpc.this[0].id
  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

##################
# Public Subnets #
##################

locals {
  create_public_subnets = local.create_vpc && local.len_public_subnets > 0
}

resource "aws_subnet" "public" {
  count = local.create_public_subnets && (local.len_public_subnets >= length(var.azs)) ? local.len_public_subnets : 0
  vpc_id = local.vpc_id
  
}