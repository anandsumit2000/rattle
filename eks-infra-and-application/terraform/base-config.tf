terraform {
  required_version = ">=1.4.0"
  required_providers {
    aws = {
            source = "hashicorp/aws"
            version = "5.44.0"
    }
  }
  backend "s3" {
    bucket = "rattle-assignment"
    key = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}