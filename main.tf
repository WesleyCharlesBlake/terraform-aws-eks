module "eks" {
  source       = "./modules/eks"
  cluster-name = "${var.cluster-name}"
  aws-region   = "${var.aws-region}"
}
