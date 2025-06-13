# Security Group para RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  # Permitir acceso desde los nodos EKS (puerto PostgreSQL)
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_to_rds_sg.id]
    description     = "PostgreSQL access from EKS nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "rds-security-group"
  }
}

# Security Group para permitir que EKS acceda a RDS
resource "aws_security_group" "eks_to_rds_sg" {
  name        = "eks-to-rds-security-group"
  description = "Security group for EKS nodes to access RDS"
  vpc_id      = var.vpc_id

  # Regla de salida para PostgreSQL
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "PostgreSQL access to RDS"
  }

  tags = {
    Name = "eks-to-rds-security-group"
  }
}