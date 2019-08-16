# EKS Terraform module

module "eks" {
  source                  = "./modules/eks"
  aws-region              = var.aws-region
  availability-zones      = var.availability-zones
  cluster-name            = var.cluster-name
  k8s-version             = var.k8s-version
  node-instance-type      = var.node-instance-type
  kublet-extra-args       = var.kublet-extra-args
  root-block-size         = var.root-block-size
  desired-capacity        = var.desired-capacity
  max-size                = var.max-size
  min-size                = var.min-size
  public-desired-capacity = var.public-desired-capacity
  public-max-size         = var.public-max-size
  public-min-size         = var.public-min-size
  vpc-subnet-cidr         = var.vpc-subnet-cidr
  private-subnet-cidr     = var.private-subnet-cidr
  public-subnet-cidr      = var.public-subnet-cidr
  db-subnet-cidr          = var.db-subnet-cidr
  eks-cw-logging          = var.eks-cw-logging
  ec2-key                 = var.ec2-key
}

