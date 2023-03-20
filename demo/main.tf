resource "aws_network_interface" "eni1" {
  count = var.ip_pool_cnt/2
  subnet_id = var.subnet_ids[0]

  tags = {
    "network-interface-manager-pool" = "${var.tag_value}"
    Name = "network-interface-manager-pool-eni"
  }
}

resource "aws_network_interface" "eni2" {
  count = var.ip_pool_cnt/2
  subnet_id = var.subnet_ids[1]

  tags = {
    "network-interface-manager-pool" = "${var.tag_value}"
    Name = "network-interface-manager-pool-eni"
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }
}

resource "aws_security_group" "ec2sg_web" {
  vpc_id      = var.vpc_id
  name        = "${var.tag_value}-sg"
  description = "alb sg"

  tags = {
    Name = "${var.tag_value}-sg"
  }

  ingress {
    to_port         = 22
    from_port       = 22
    protocol        = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "ssh from the internet"
  }

  ingress {
    to_port         = -1
    from_port       = -1
    protocol        = "icmp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "ping from the internet"
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "lt-web" {
  name          = "${var.tag_value}-lt"
  image_id      = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
    }
  }
  
  vpc_security_group_ids = [aws_security_group.ec2sg_web.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.tag_value}"
      "network-interface-manager-pool" = "${var.tag_value}"
    }
  }

  tags = {
    Name = "${var.tag_value}-lt"
  }
}

resource "aws_autoscaling_group" "asg" {
  name             = "${var.tag_value}-asg"
  min_size         = 1
  max_size         = 4
  desired_capacity = 2
  launch_template {
    id      = aws_launch_template.lt-web.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.subnet_ids
  force_delete        = true
}