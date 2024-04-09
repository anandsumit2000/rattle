aws_region = "us-east-1"

vpc_name = "Main"

vpc_cidr_block = "10.0.0.0/16"

private_subnet_cidrs = [
  {
    name = "Private Subnet 1"
    cidr = "10.0.11.0/24"
    az   = "us-east-1a"
  },
  {
    name = "Private Subnet 2"
    cidr = "10.0.15.0/24"
    az   = "us-east-1d"
  },
]

public_subnet_cidrs = [
  {
    name = "Public Subnet 1"
    cidr = "10.0.1.0/24"
    az   = "us-east-1a"
  },
  {
    name = "Public Subnet 2"
    cidr = "10.0.2.0/24"
    az   = "us-east-1d"
  },
]

database_subnet_cidrs = [
  {
    name = "Database Subnet 2"
    cidr = "10.0.16.0/24"
    az   = "us-east-1d"
  },
  {
    name = "Database Subnet 1"
    cidr = "10.0.12.0/24"
    az   = "us-east-1a"
  },
]

