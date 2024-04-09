variable "aws_region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "private_subnet_cidrs" {
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "public_subnet_cidrs" {
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "database_subnet_cidrs" {
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}