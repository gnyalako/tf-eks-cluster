###############################################################################
# Variables - Environment
###############################################################################
variable "aws_account_id" {
  description = "(Required) The AWS Account ID."
}

variable "region" {
  description = "(Optional) Region where resources will be created."
  default     = "us-east-1"
}

variable "environment" {
  description = "(Optional) The name of the environment, e.g. Production, Development, etc."
  default     = "Development"
}

###############################################################################
# Variables - Base Network
###############################################################################
variable "vpc_cidr" {
  description = "(Optional) CIDR range for the VPC."
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "(Optional) Name of the VPC."
  default     = null
}

###############################################################################
# Variables - EKS
###############################################################################
variable "cluster_name" {
  description = "(Optional) Name of the EKS Cluster."
  default     = "devops-cluster"
}

variable "cluster_version" {
  description = "(Optional) Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)."
  default     = "1.24"
}

variable "cluster_endpoint_public_access" {
  description = "(Optional) Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  default     = true
}

variable "manage_aws_auth_configmap" {
  description = "(Optional) Determines whether to manage the aws-auth configmap."
  default     = true
}

###############################################################################
# Variables - EKS Node Group
###############################################################################
variable "node_group_name" {
  description = "(Optional) Name of the EKS Cluster Node Group."
  default     = null
}

variable "node_group_instance_type" {
  description = "(Optional) Instance size to be used by the EKS Node Group."
  default     = "t3.large"
}

variable "node_group_capacity_type" {
  description = "(Optional) Capacity Type to be used by the EKS Node Group."
  default     = "SPOT"
}

variable "node_group_min_size" {
  description = "(Optional) Minimum number of instance/s for EKS Cluster Node Group."
  default     = 1
}

variable "node_group_max_size" {
  description = "(Optional) Maximum number of instance/s for EKS Cluster Node Group."
  default     = 5
}

variable "node_group_desired_size" {
  description = "(Optional) Desired number of instance/s for EKS Cluster Node Group."
  default     = 1
}
