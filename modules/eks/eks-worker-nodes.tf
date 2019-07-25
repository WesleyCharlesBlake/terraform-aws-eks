# EKS Worker Nodes Resources

variable "k8s-version" {}

variable node-instance-type {}
variable "desired-capacity" {}
variable "max-size" {}
variable "min-size" {}



# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml
# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html

locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

module "eks-nodes-asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  name = "eks-nodes-asg"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "eks-nodes"

  image_id = data.aws_ami.eks-worker-ami.id
  instance_type = var.node-instance-type
  security_groups = [data.aws_security_group.node.id]
  associate_public_ip_address = false
  recreate_asg_when_lc_changes = true

  root_block_device = [
    {
      volume_size = "10"
      volume_type = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name = "eks-nodegroup"
  vpc_zone_identifier = data.aws_subnet_ids.private.ids

  health_check_type = "EC2"

  min_size = var.min-size
  max_size = var.max-size
  desired_capacity = var.desired-capacity
  wait_for_capacity_timeout = 0

  key_name = var.ec2-key

  iam_instance_profile = "${aws_iam_instance_profile.node.name}"
  user_data = local.eks-node-userdata

  tags = [
    {
      key                 = "kubernetes.io/cluster/${var.cluster-name}"
      value               = "owned"
      propagate_at_launch = true
    }
  ]  
}
