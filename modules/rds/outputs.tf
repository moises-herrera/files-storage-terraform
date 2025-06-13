output "db_instance_address" {
  value = aws_db_instance.main.address
}

output "db_hostname" {
  value = aws_db_instance.main.endpoint
}

output "db_port" {
  value = aws_db_instance.main.port
}

output "db_name" {
  value = aws_db_instance.main.db_name
}

output "db_user" {
  value = aws_db_instance.main.username
}

output "db_master_user_secret" {
  value = aws_db_instance.main.master_user_secret[0].secret_arn
}
