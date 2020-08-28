### VPC

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.7.0"

  name = "${var.cluster-name}-eks-vpc"

  cidr = var.vpc-subnet-cidr

  azs              = var.availability-zones
  private_subnets  = var.private-subnet-cidr
  public_subnets   = var.public-subnet-cidr
  database_subnets = var.db-subnet-cidr

  create_database_subnet_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true

  tags = {
    Name                                        = "${var.cluster-name}-vpc"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }

  public_subnet_tags = {
    Name                                        = "${var.cluster-name}-eks-public"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
  private_subnet_tags = {
    Name                                        = "${var.cluster-name}-eks-private"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
  database_subnet_tags = {
    Name = "${var.cluster-name}-eks-db"
  }
}