module "app_vpc" {
  source          = "./modules/vpc"
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
  cluster_name    = var.cluster_name
}

module "app_iam" {
  source = "./modules/iam"
  cluster_name = var.cluster_name
}

module "app_security_groups" {
  source   = "./modules/security-groups"
  vpc_id   = module.app_vpc.vpc_id
  vpc_cidr = module.app_vpc.vpc_cidr
}

module "app_rds" {
  source             = "./modules/rds"
  subnet_ids         = module.app_vpc.private_subnets
  security_group_ids = [module.app_security_groups.rds_security_group_id]
  db_name            = var.db_name
  db_user            = var.db_user
}

module "app_eks" {
  source       = "./modules/eks"
  eks_version  = var.eks_version
  cluster_name = var.cluster_name
  vpc_id       = module.app_vpc.vpc_id
  subnet_ids   = module.app_vpc.private_subnets
  
  additional_security_group_ids = [module.app_security_groups.eks_to_rds_security_group_id]
  
  depends_on = [module.app_security_groups]
}
