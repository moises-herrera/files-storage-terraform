variable "subnet_ids" {
  description = "List of subnets IDs for RDS"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for RDS"
  type        = list(string)
}

variable "db_name" {
  description = "Database name for RDS"
  type        = string
}

variable "db_user" {
  description = "Database user for RDS"
  type        = string
}