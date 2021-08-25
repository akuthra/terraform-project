########################################################################################################################
#### Common ####
################

provider "aws" {
  region = var.aws_region

}

data "aws_availability_zones" "available" {}

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}


########################################################################################################################
#### Application ####
#####################
module "ecs_cluster" {
  source           = "./modules/cluster"
  name             = "syncron-acs-${var.stage}"
  vpc_id           = var.vpc_id
  vpc_subnets      = var.private_subnet_ids
  instance_type    = var.app_instance_type
  aws_region       = var.aws_region
  asg_desired_size = var.desired_instance_count
  asg_max_size     = var.max_instance_count
  asg_min_size     = var.min_instance_count
  tags             = var.tags
}

module "alb" {
  source           = "./modules/alb"
  name             = "syncron-acs-${var.stage}"
  backend_sg_id    = module.ecs_cluster.instance_sg_id
  vpc_id           = var.vpc_id
  vpc_subnets      = var.private_subnet_ids
  aws_region       = var.aws_region
  aws_account_name = var.aws_account_name
  tags             = var.tags
  idle_timeout     = var.idle_timeout
}

module "ecs_service_app" {
  source               = "./modules/service"
  service_name         = "acs-${var.stage}"
  alb_target_group_arn = module.alb.target_group_arns[0]
  cluster              = module.ecs_cluster.cluster_id
  container_name       = "${var.service-name}-${var.stage}"

  log_groups = [
    "${var.service-name}-${var.stage}",
  ]

  tags = var.tags
 task_template = templatefile("${path.module}/ecs_task-definition.json", {
    name       = "${var.service-name}-${var.stage}",
    ecr_repo   = var.service-repo-name,
    repository_name = "acs",
    image_hash = var.service-image-hash,
    aws_region = var.aws_region,
    account_id = var.aws_account_id,
    stage      = var.stage
  })

  aws_region           = var.aws_region
  desired_count        = var.containers_count
  max_containers_count = var.max_containers_count
  aws_iam_role_arn     = var.aws_iam_role_arn
  alb_arn_suffix       = module.alb.alb_arn_suffix
  asg_name             = module.ecs_cluster.asg_name
  target_group_suffix  = module.alb.target_group_suffix[0]
}

########################################################################################################################