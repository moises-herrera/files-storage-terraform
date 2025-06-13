resource "aws_secretsmanager_secret" "app_credentials" {
  name                    = "cloudnest-app-credentials"
  description             = "Credentials for CloudNest application"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app_credentials" {
  secret_id = aws_secretsmanager_secret.app_credentials.id
  secret_string = jsonencode({
    DB_HOST                = var.db_hostname
    DB_USER                = var.db_user
    DB_PORT                = tostring(var.db_port)
    DB_NAME                = var.db_name
    MASTER_USER_SECRET_ARN = var.db_master_user_secret
  })
}
