resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.prefix}-vpc" })
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_az
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.prefix}-public-1a" })
}

resource "aws_subnet" "private_master_1a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_master_subnet_cidr
  availability_zone = var.private_master_az
  tags              = merge(var.tags, { Name = "${var.prefix}-private-master-1a" })
}

resource "aws_subnet" "private_replica_1c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_replica_subnet_cidr
  availability_zone = var.private_replica_az
  tags              = merge(var.tags, { Name = "${var.prefix}-private-replica-1c" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.prefix}-igw" })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, { Name = "${var.prefix}-public-rt" })
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  vpc  = true
  tags = merge(var.tags, { Name = "${var.prefix}-nat-eip" })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1a.id
  tags          = merge(var.tags, { Name = "${var.prefix}-nat-gw" })

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.tags, { Name = "${var.prefix}-private-rt" })
}

resource "aws_route_table_association" "private_master_assoc" {
  subnet_id      = aws_subnet.private_master_1a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_replica_assoc" {
  subnet_id      = aws_subnet.private_replica_1c.id
  route_table_id = aws_route_table.private_rt.id
}
