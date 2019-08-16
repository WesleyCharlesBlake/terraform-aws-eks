variable "public-min-size" {
}

variable "public-max-size" {
}

variable "public-desired-capacity" {
}


module "public-eks-nodes-asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  name    = "public-eks-nodes-asg"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "${var.cluster-name}-node-public-lc"

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
  asg_name            = "${var.cluster-name}-node-public"
  vpc_zone_identifier = data.aws_subnet_ids.public.ids

  health_check_type = "EC2"

  min_size                  = var.public-min-size
  max_size                  = var.public-max-size
  desired_capacity          = var.public-desired-capacity
  wait_for_capacity_timeout = 0

  key_name = var.ec2-key

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
