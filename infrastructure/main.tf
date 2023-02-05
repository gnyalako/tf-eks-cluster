###############################################################################
# Providers
###############################################################################
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

###############################################################################
# Terraform main config
###############################################################################
terraform {
  required_version = ">= 1.1.5"
  required_providers {
    aws = "~> 3.74.0"
  }
}

###############################################################################
# Data Sources
###############################################################################
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

###############################################################################
# Locals
###############################################################################
locals {
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name == null ? "${var.cluster_name}-vpc" : var.vpc_name
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  cluster_name = var.cluster_name
  region       = var.region

  tags = {
    Environment = var.environment
  }
}

###############################################################################
# Base Network
###############################################################################
module "base_network" {
  source = "../modules/vpc"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

###############################################################################
# KMS for EKS
###############################################################################
module "kms" {
  source = "../modules/kms"

  aliases               = ["eks/${local.cluster_name}"]
  description           = "${local.cluster_name} cluster encryption key"
  enable_default_policy = true
  key_owners            = [data.aws_caller_identity.current.arn]

  tags = local.tags
}
