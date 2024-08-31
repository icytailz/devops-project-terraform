locals {
  create_vpc = var.create_vpc

  len_public_subnets = length(var.public_subnets)
  len_private_subnets = length(var.private_subnets)

  max_subnet_length = max (
    local.len_public_subnets,
    local.len_private_subnets,
  )

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

  tags = merge(
    {
      Name = try(
        var.public_subnet_names[count.index], format("${var.name}-${var.public_subnet_suffix}-%s", element(var.azs, count.index))
      )
    },
    var.tags,
    var.public_subnet_tags,
    lookup(var.public_subnet_tags_per_az, element(var.azs, count.index),{})
  )
}

locals {
  num_public_route_tables = var.create_multiple_public_route_tables ? local.len_public_subnets : 1
}

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id
  count = local.create_public_subnets ? local.num_public_route_tables : 0

  tags = merge(
    {
      "Name" = var.create_multiple_public_route_tables ? format("${var.name}-${var.public_subnet_suffix}-%s", element(var.azs, count.index),) : "${var.name}-${var.public_subnet_suffix}"
    },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route_table_association" "public" {
  count = local.create_public_subnets ? local.len_public_subnets : 0

  subnet_id = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(aws_route_table.public[*].id, var.create_multiple_public_route_tables ? count.index : 0)
}

resource "aws_route" "public_internet_gateway" {
  count = local.create_public_subnets && var.create_igw ? local.num_public_route_tables : 0
  route_table_id = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.this[0].id
  
  timeouts {
    create = "5m"
  }
}

##################
# Private Subnets #
##################

locals {
  create_private_subnets = local.create_vpc && local.len_private_subnets > 0
}

resource "aws_subnet" "private" {
  count = local.create_private_subnets && (local.len_private_subnets >= length(var.azs)) ? local.len_private_subnets : 0
  vpc_id = local.vpc_id

  tags = merge(
    {
      Name = try(
        var.private_subnet_names[count.index], format("${var.name}-${var.private_subnet_suffix}-%s", element(var.azs, count.index))
      )
    },
    var.tags,
    var.private_subnet_tags,
    lookup(var.private_subnet_tags_per_az, element(var.azs, count.index),{})
  )
}

resource "aws_route_table" "private" {
  vpc_id = local.vpc_id
  count = local.create_private_subnets ? local.num_public_route_tables : 0

  tags = merge(
    {
      "Name" = var.create_multiple_public_route_tables ? format("${var.name}-${var.public_subnet_suffix}-%s", element(var.azs, count.index),) : "${var.name}-${var.public_subnet_suffix}"
    },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route_table_association" "public" {
  count = local.create_public_subnets ? local.len_public_subnets : 0

  subnet_id = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(aws_route_table.public[*].id, var.create_multiple_public_route_tables ? count.index : 0)
}