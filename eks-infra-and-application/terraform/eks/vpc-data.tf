data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = "rattle-assignment"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  database_subnets = data.terraform_remote_state.core.outputs.database_subnets
  private_subnets  = data.terraform_remote_state.core.outputs.private_subnets
  public_subnets   = data.terraform_remote_state.core.outputs.public_subnets
  vpc_id           = data.terraform_remote_state.core.outputs.vpc_id
}

data "aws_subnet" "public_1" {
  id = local.public_subnets[0]
}

data "aws_subnet" "public_2" {
  id = local.public_subnets[1]
}

data "aws_subnet" "private_1" {
  id = local.private_subnets[0]
}

data "aws_subnet" "private_2" {
  id = local.private_subnets[1]
}

data "aws_vpc" "vpc" {
  id = local.vpc_id
}
