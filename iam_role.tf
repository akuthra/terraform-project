resource "aws_iam_role" "acs-role" {
  name = "acs-ecs-role-${var.stage}-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
	{
	  "Sid": "",
	  "Effect": "Allow",
	  "Principal": {
		"Service": [ "ecs-tasks.amazonaws.com",
        "ec2.amazonaws.com",
        "application-autoscaling.amazonaws.com",
        "ecs.amazonaws.com"
         ]
	  },
	  "Action": "sts:AssumeRole"
	}
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_role_policy" {
  role       = aws_iam_role.acs-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "ecr_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.acs-role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.acs-role.name
}

resource "aws_iam_role_policy_attachment" "code_commit_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
  role       = aws_iam_role.acs-role.name
}

resource "aws_iam_role_policy_attachment" "elb_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.acs-role.name
}




// ECS instance role
resource "aws_iam_role" "instance_role" {
  name = "${var.service-name}-ecs-instance-role-${var.stage}-${var.aws_region}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": "ec2.amazonaws.com"
        }
    }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_role_profile" {
  name = "ecs_instance_role_profile-${var.stage}"
  role = aws_iam_role.instance_role.name
}

// Spot instace role
resource "aws_iam_role" "spot_instance_role" {
  name = "${var.service-name}-spot-instance-role-${var.stage}-${var.aws_region}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": "spotfleet.amazonaws.com"
        }
    }
    ]
}
EOF

  tags = var.tags
}

// Allow spot-instance-role to create, terminate and tag spot instances
resource "aws_iam_role_policy_attachment" "spot_request_policy" {
  role       = aws_iam_role.spot_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}



