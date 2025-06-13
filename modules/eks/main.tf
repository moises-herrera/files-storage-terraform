module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  cluster_additional_security_group_ids = var.additional_security_group_ids

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  eks_managed_node_group_defaults = {
    ami_type               = "AL2023_x86_64_STANDARD"
    vpc_security_group_ids = var.additional_security_group_ids
  }

  eks_managed_node_groups = {
    system = {
      name           = "system-nodes"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      labels = {
        role = "system"
      }
      taints = [{
        key    = "CriticalAddonsOnly"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
    }

    general_purpose = {
      name           = "general-purpose-nodes"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      labels = {
        role = "general-purpose"
      }
    }

    frontend = {
      name           = "frontend-nodes"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      labels = {
        role = "frontend"
      }
      taints = [{
        key    = "app"
        value  = "frontend"
        effect = "NO_SCHEDULE"
      }]
    }

    backend = {
      name           = "backend-nodes"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 1
      desired_size   = 1

      vpc_security_group_ids = var.additional_security_group_ids

      labels = {
        role = "backend"
      }
      taints = [{
        key    = "app"
        value  = "backend"
        effect = "NO_SCHEDULE"
      }]
    }
  }
}

# EBS CSI Driver
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.58.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

# AWS Load Balancer Controller
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name_prefix = "AWSLoadBalancerController"
  description = "EKS AWS Load Balancer Controller policy"
  policy      = file("${path.module}/../iam/AWSLoadBalancerController.json")
}

module "irsa-aws-load-balancer-controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.58.0"

  create_role                   = true
  role_name                     = "AmazonEKSLoadBalancerControllerRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.aws_load_balancer_controller.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa-aws-load-balancer-controller.iam_role_arn
    }
  }

  depends_on = [module.eks]
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [
    module.irsa-aws-load-balancer-controller,
    kubernetes_service_account.aws_load_balancer_controller
  ]
}

# IAM Role for Backend Service Account to access Secrets Manager
resource "aws_iam_role" "cloudnest_backend_secrets_role" {
  name = "cloudnest-backend-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::802041176838:oidc-provider/${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:cloudnest-app:backend-service-account"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
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
          "arn:aws:secretsmanager:us-east-1:802041176838:secret:rds*",
          "arn:aws:secretsmanager:us-east-1:802041176838:secret:app-*",
          "arn:aws:secretsmanager:us-east-1:802041176838:secret:cloudnest*",
        ]
      }
    ]
  })
}
