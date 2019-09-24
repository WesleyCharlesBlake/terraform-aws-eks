# EKS Worker Nodes Resources

variable "k8s-version" {}

variable node-instance-type {}
variable "root-block-size" {}
variable "desired-capacity" {}
variable "max-size" {}
variable "min-size" {}
variable "kublet-extra-args" {}


locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority.0.data}' '${var.cluster-name}' --kubelet-extra-args '${var.kublet-extra-args}'
USERDATA
}

module "eks-nodes-asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  name    = "${var.cluster-name}-eks-nodes"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "${var.cluster-name}-node-lc"

  image_id                     = data.aws_ami.eks-worker-ami.id
  instance_type                = var.node-instance-type
  security_groups              = [data.aws_security_group.node.id]
  associate_public_ip_address  = false
  recreate_asg_when_lc_changes = true

  root_block_device = [
    {
      volume_size           = "${var.root-block-size}"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name            = "${var.cluster-name}-node"
  vpc_zone_identifier = data.aws_subnet_ids.private.ids

  health_check_type = "EC2"

  min_size                  = var.min-size
  max_size                  = var.max-size
  desired_capacity          = var.desired-capacity
  wait_for_capacity_timeout = 0

  key_name = aws_key_pair.deployer.key_name

  iam_instance_profile = "${aws_iam_instance_profile.node.name}"
  user_data            = local.eks-node-userdata

  tags = [
    {
      key                 = "kubernetes.io/cluster/${var.cluster-name}"
      value               = "owned"
      propagate_at_launch = true
    }
  ]
}
