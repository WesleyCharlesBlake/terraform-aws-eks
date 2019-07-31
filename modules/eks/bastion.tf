### bastion

variable "ec2-key" {}

### bastion hosts
module "bastion-asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  name    = "bastion-asg"

  lc_name = "bastion-lc"

  image_id                     = data.aws_ami.bastion.id
  instance_type                = "t2.small"
  security_groups              = [data.aws_security_group.bastion.id]
  associate_public_ip_address  = true
  recreate_asg_when_lc_changes = true

  root_block_device = [
    {
      volume_size           = "10"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name                  = "bastion"
  vpc_zone_identifier       = data.aws_subnet_ids.public.ids
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  key_name                  = var.ec2-key

  tags = [
    {
      key                 = "Name"
      value               = "bastion"
      propagate_at_launch = true
    }
  ]

}
