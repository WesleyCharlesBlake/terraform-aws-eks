# EKS Terraform module

module "eks" {
  source             = "./modules/eks"
  cluster-name       = "${var.cluster-name}"
  k8s-version        = "${var.k8s-version}"
  aws-region         = "${var.aws-region}"
  node-instance-type = "${var.node-instance-type}"
  desired-capacity   = "${var.desired-capacity}"
  max-size           = "${var.max-size}"
  min-size           = "${var.min-size}"
  vpc-subnet-cidr    = "${var.vpc-subnet-cidr}"
}
