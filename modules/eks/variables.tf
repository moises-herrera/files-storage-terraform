variable "eks_version" {
  description = "EKS version to use"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the nodes in the EKS cluster"
  type        = list(string)
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach to EKS nodes"
  type        = list(string)
  default     = []
}
