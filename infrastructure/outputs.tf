###############################################################################
# Base Network Output
###############################################################################
output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.base_network.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC."
  value       = module.base_network.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets."
  value       = module.base_network.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets."
  value       = module.base_network.public_subnets
}

output "intra_subnets" {
  description = "List of IDs of intra subnets."
  value       = module.base_network.intra_subnets
}

###############################################################################
# EKS KMS Key
###############################################################################
output "eks_kms_key_arn" {
  description = "The ARN of the EKS KMS Key."
  value       = module.kms.key_arn
}

###############################################################################
# EKS Output
###############################################################################
output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the EKS cluster."
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_platform_version" {
  description = "Platform version for the EKS cluster."
  value       = module.eks.cluster_platform_version
}

output "eks_cluster_version" {
  description = "The Kubernetes version for the cluster."
  value       = module.eks.cluster_version
}

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created."
  value       = module.eks.eks_managed_node_groups
}

output "eks_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider."
  value       = module.eks.cluster_oidc_issuer_url
}
