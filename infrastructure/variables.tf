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
