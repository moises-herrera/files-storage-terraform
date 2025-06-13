data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_iam_role" "cloudnest_backend_secrets_role" {
  name = "cloudnest-backend-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::802041176838:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:cloudnest-app:backend-service-account"
            "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "cloudnest-backend-secrets-role"
  }
}

resource "aws_iam_role_policy" "cloudnest_backend_secrets_policy" {
  name = "cloudnest-backend-secrets-policy"
  role = aws_iam_role.cloudnest_backend_secrets_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:us-east-1:802041176838:secret:dev/app/*"
        ]
      }
    ]
  })
}
