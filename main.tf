#
# Provider Configuration
#

provider "aws" {
  region = "us-west-2"
}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "./modules/vpc"
}

module "eks-cluster" {
  source = "./modules/eks-cluster"
}

module "eks-nodes" {
  source = "./modules/eks-nodes"
}

module "kubeconfig" {
  source = "./modules/config"
}
