resource "aws_db_subnet_group" "main" {
  name       = "app-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_parameter_group" "main" {
  name        = "app-db-params"
  family      = "postgres17"
  description = "Custom params"
  parameter {
    name  = "log_min_duration_statement"
    value = "500"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "app-db"
  engine                 = "postgres"
  engine_version         = "17.2"
  instance_class         = "db.t4g.medium"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_user
  manage_master_user_password = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  parameter_group_name   = aws_db_parameter_group.main.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  tags = {
    Name = "app-postgresql-db"
    Environment = "development"
  }
}
