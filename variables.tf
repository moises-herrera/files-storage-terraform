# Global variables for the Terraform configuration

# General variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# VPC
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "app"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# EKS
variable "eks_version" {
  description = "EKS version to use"
  type        = string
  default     = "1.33"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

# RDS
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "files_storage_db"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "postgres"
}