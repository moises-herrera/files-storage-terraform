output "db_secret_arn" {
  description = "ARN of the app credentials secret"
  value       = aws_secretsmanager_secret.app_credentials.arn
}
