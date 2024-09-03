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
  cidr_block = element(concat(var.public_subnets, [""]), count.index)

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
  cidr_block = element(concat(var.private_subnets, [""]), count.index)

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
#There are as many rooting table as the number of NAT g gateway
resource "aws_route_table" "private" {
  vpc_id = local.vpc_id
  count = local.create_private_subnets && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  tags = merge(
    {
      "Name" = var.single_nat_gateway ? "${var.name}-${var.private_subnet_suffix}" : format("${var.name}-${var.private_subnet_suffix}-%s", element(var.azs, count.index),) 
    },
    var.tags,
    var.private_route_table_tags,
  )
}

resource "aws_route_table_association" "private" {
  count = local.create_private_subnets ? local.len_private_subnets : 0

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, var.single_nat_gateway ? 0 : count.index)
}


######################
## Internet Gateway ##
######################

resource "aws_internet_gateway" "this" {
  count = local.create_public_subnets && var.create_igw ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.igw_tags,
  )
}

#################
## NAT Gateway ##
#################

locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
  nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat[*].id
}

resource "aws_eip" "nat" {
  count = local.create_vpc && var.enable_nat_gateway && !var.reuse_nat_ips ? local.nat_gateway_count : 0
  domain = "vpc"
  tags = merge (
    {
      "Name" = format(
        "${var.name}-%s",
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_eip_tags,
  )
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index
  )
  subnet_id = element(
    aws_subnet.public[*].id,
    var.single_nat_gateway ? 0 : count.index
  )

  tags = merge(
    {
      "Name" = format(
        "${var.name}-%s",
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [ aws_internet_gateway.this ]
  
}

resource "aws_route" "private_nat_gateway" {
  count = local.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0
  route_table_id = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
  
}