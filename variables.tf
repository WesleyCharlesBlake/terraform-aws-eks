#
# Variables Configuration
#

variable "cluster-name" {
  default = "terraform-eks"
  type    = "string"
}

variable "aws-region" {
  default = "us-west-2"
  type    = "string"
}
