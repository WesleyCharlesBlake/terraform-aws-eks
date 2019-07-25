#
# Provider Configuration

variable "aws-region" {}

provider "aws" {
  region = var.aws-region
}

provider "http" {}
