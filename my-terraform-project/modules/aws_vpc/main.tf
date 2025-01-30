resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true

  tags = merge({ Name = "${var.name}-public-${count.index + 1}" }, var.tags)
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets[count.index]

  tags = merge({ Name = "${var.name}-private-${count.index + 1}" }, var.tags)
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge({ Name = "${var.name}-igw" }, var.tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge({ Name = "${var.name}-public-rt" }, var.tags)
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge({ Name = "${var.name}-nat-eip" }, var.tags)
}

resource "aws_nat_gateway" "main" {
  count           = var.enable_nat_gateway ? 1 : 0
  allocation_id   = aws_eip.nat[0].id
  subnet_id       = aws_subnet.public[0].id

  tags = merge({ Name = "${var.name}-nat-gw" }, var.tags)
}

resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge({ Name = "${var.name}-private-rt" }, var.tags)
}

resource "aws_route" "private" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[0].id : aws_route_table.public.id
}

