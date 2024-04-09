terraform {
  required_version = ">=1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.44.0"
    }
  }
  backend "s3" {
    region = "us-east-1"
    bucket = "rattle-assignment"
    key    = "vpc/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}