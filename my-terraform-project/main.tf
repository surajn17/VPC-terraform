provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "./modules/aws_vpc"
  name                 = "my-vpc"
  cidr_block           = "10.0.0.0/16"
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Environment = "dev"
    Owner       = "DevOps Team"
  }
}

