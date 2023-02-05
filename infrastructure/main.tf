###############################################################################
# Providers
###############################################################################
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

###############################################################################
# Terraform main config
###############################################################################
terraform {
  required_version = ">= 1.1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
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

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  node_group_name = var.node_group_name == null ? "${var.cluster_name}-ng" : var.node_group_name

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

###############################################################################
# EKS
###############################################################################
module "eks" {
  source = "../modules/eks"

  cluster_name                   = local.cluster_name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  # networking settings
  vpc_id                   = module.base_network.vpc_id
  subnet_ids               = module.base_network.private_subnets
  control_plane_subnet_ids = module.base_network.intra_subnets

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # External encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    "${local.node_group_name}" = {
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      instance_types = [var.node_group_instance_type]
      capacity_type  = var.node_group_capacity_type
      labels = {
        Environment = var.environment
      }

      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      tags = local.tags
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = var.manage_aws_auth_configmap

  enable_irsa = true

  tags = local.tags
}

###############################################################################
# Cluster Autoscaler
###############################################################################
module "cluster_autoscaler" {
  source = "../modules/iam-cluster-autoscaler"

  cluster_name         = module.eks.cluster_name
  issuer_url           = module.eks.cluster_oidc_issuer_url
  kubernetes_namespace = "kube-system"
}

###############################################################################
# Setup Kubeconfig on local machine
###############################################################################
resource "null_resource" "update-kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}"
  }
  depends_on = [module.base_network, module.kms, module.eks, module.cluster_autoscaler]
}
