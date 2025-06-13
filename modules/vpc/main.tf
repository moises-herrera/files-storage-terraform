module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.21.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  tags = {
    Name = "${var.vpc_name}-vpc"
  }

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = false

  public_subnet_tags_per_az = {
    for index, az in var.azs : az => {
      Name = "${var.vpc_name}-subnet-public-${index + 1}-${az}"
    }
  }

  private_subnet_tags_per_az = {
    for index, az in var.azs : az => {
      Name = "${var.vpc_name}-subnet-private-${index + 1}-${az}"
    }
  }

  public_route_table_tags = {
    Name = "${var.vpc_name}-public-route-table"
  }

  private_route_table_tags = {
    Name = "${var.vpc_name}-private-route-table"
  }

  igw_tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }

  nat_gateway_tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = 1
  }
}
