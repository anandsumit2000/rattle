locals {
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(local.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidrs[count.index].cidr
  availability_zone       = local.public_subnet_cidrs[count.index].az
  map_public_ip_on_launch = true
  tags = {
    Name = local.public_subnet_cidrs[count.index].name
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(local.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_cidrs[count.index].cidr
  availability_zone = local.private_subnet_cidrs[count.index].az

  tags = {
    Name = local.private_subnet_cidrs[count.index].name
  }
}

resource "aws_subnet" "database_subnets" {
  count = length(local.database_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.database_subnet_cidrs[count.index].cidr
  availability_zone = local.database_subnet_cidrs[count.index].az

  tags = {
    Name = local.database_subnet_cidrs[count.index].name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "nat_gateway" {
  count = length(aws_subnet.public_subnets)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "NAT Gateway ${count.index + 1}"
  }
}

resource "aws_eip" "nat" {
  count = length(aws_subnet.public_subnets)

}

resource "aws_route_table" "private_route_table" {
  count = length(aws_subnet.private_subnets)

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = aws_subnet.private_subnets[count.index] // Iterate over the private subnets

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gateway[count.index % length(aws_nat_gateway.nat_gateway)].id // Use modulus to cycle through the NAT gateways based on count.index
    }
  }

  tags = {
    Name = "Private Route Table ${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_subnet_associations" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Security group for public tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow outbound access to anywhere
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Security group for private tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Security group for database tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306 // MySQL port
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.private_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
