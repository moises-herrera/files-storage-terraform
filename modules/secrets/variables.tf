variable "db_hostname" {
  description = "Hostname of the RDS instance"
  type        = string
}

variable "db_port" {
  description = "Port of the RDS instance"
  type        = number
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_master_user_secret" {
  description = "Master user secret ARN"
  type        = string
}
