output "db_instance_address" {
  value = aws_db_instance.main.address
}

output "db_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
