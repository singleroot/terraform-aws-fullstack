terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# Module 1: Networking
module "networking" {
  source      = "../../modules/networking"
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

# Module 2: EC2
module "ec2" {
  source            = "../../modules/ec2"
  environment       = var.environment
  instance_type     = var.instance_type
  subnet_id         = module.networking.public_subnet_ids[0]
  security_group_id = module.networking.ec2_security_group_id
}

# Module 3: RDS (only create if var.create_rds = true)
module "rds" {
  count  = var.create_rds ? 1 : 0 # count=0 means don't create it
  source = "../../modules/rds"

  environment        = var.environment
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id  = module.networking.rds_security_group_id
}

# Module 4: S3 + CloudFront
module "s3" {
  source      = "../../modules/s3"
  environment = var.environment
  account_id  = data.aws_caller_identity.current.account_id
}
