terraform {
  required_version = ">= 0.12"
}

resource "aws_security_group_rule" "instance_in_alb" {
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "tcp"
  source_security_group_id = module.alb_sg_https.this_security_group_id
  security_group_id        = var.backend_sg_id
}

module "alb_sg_https" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.4.0"

  name   = "${var.name}-alb"
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = var.tags
}

module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "5.1.0"
  name               = var.name
  load_balancer_type = "application"
  security_groups    = [module.alb_sg_https.this_security_group_id]
  subnets            = var.vpc_subnets
  vpc_id             = var.vpc_id

  target_groups = [
    {
      name_prefix      = "acs"
      backend_protocol = var.backend_protocol
      backend_port     = var.backend_port
      target_type      = "instance"
      health_check = {
        path = "/actuator/health"
      }
    }
  ]

  internal = true

  http_tcp_listeners = [
    {
      port               = var.backend_port
      protocol           = var.backend_protocol
      target_group_index = 0
    }
  ]

  idle_timeout = var.idle_timeout
  tags         = var.tags
}

