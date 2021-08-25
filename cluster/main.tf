terraform {
  required_version = ">= 0.12"
}

resource "aws_ecs_cluster" "ecs" {
  name = var.name
}

resource "aws_cloudwatch_log_group" "instance" {
  name = var.instance_log_group != "" ? var.instance_log_group : format("%s-instance", var.name)
  #tags = merge(var.tags, tomap("Name", format("%s", var.name)))
}

data "aws_iam_policy_document" "instance_policy" {
  statement {
    sid = "CloudwatchPutMetricData"

    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "InstanceLogging"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [
      aws_cloudwatch_log_group.instance.arn,
    ]
  }
}

resource "aws_iam_policy" "instance_policy" {
  name   = "${var.name}-ecs-instance-${var.aws_region}"
  path   = "/"
  policy = data.aws_iam_policy_document.instance_policy.json
}

resource "aws_iam_role" "instance" {
  name = "${var.name}-instance-role-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "instance_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.instance_policy.arn
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.name}-instance-profile-${var.aws_region}"
  role = aws_iam_role.instance.name
}

resource "aws_security_group" "instance" {
  name        = "${var.name}-container-instance"
  description = "Security Group managed by Terraform"
  vpc_id      = var.vpc_id
  #tags        = merge(var.tags, tomap("Name", format("%s-container-instance", var.name)))
}

resource "aws_security_group_rule" "instance_out_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance.id
}

data "aws_ssm_parameter" "ecs_ami_id" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_configuration" "instance" {
  name_prefix          = "${var.name}-lc"
  image_id             = data.aws_ssm_parameter.ecs_ami_id.value
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.instance.name
  user_data            = templatefile("${path.module}/user_data.sh", { ecs_cluster = aws_ecs_cluster.ecs.name })
  security_groups      = [aws_security_group.instance.id]
  key_name             = var.instance_keypair

  root_block_device {
    volume_size = var.instance_root_volume_size
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.name}-asg"

  launch_configuration = aws_launch_configuration.instance.name
  vpc_zone_identifier  = var.vpc_subnets
  max_size             = var.asg_max_size
  min_size             = var.asg_min_size
  desired_capacity     = var.asg_desired_size

  health_check_type = "EC2"

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "origin"
      value               = lookup(var.tags, "origin")
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.name}-ecs-container-instance"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = lookup(var.tags, "owner")
      propagate_at_launch = true
    },
    {
      key                 = "tenant"
      value               = lookup(var.tags, "tenant")
      propagate_at_launch = true
    },
    {
      key                 = "cost_category"
      value               = lookup(var.tags, "cost_category")
      propagate_at_launch = true
    },
    {
      key                 = "environmenttype"
      value               = lookup(var.tags, "environmenttype")
      propagate_at_launch = true
    },
    {
      key                 = "product"
      value               = lookup(var.tags, "product")
      propagate_at_launch = true
    },
  ]
}
