variable "alb_target_group_arn" {
  description = "ARN of the ALB target group that should be associated with the ECS service"
}

variable "alb_arn_suffix" {
}

variable "target_group_suffix" {
}

variable "asg_name" {
}

variable "cluster" {
  description = "Name of the ECS cluster to create service in"
}

variable "container_name" {
  description = "Name of the container that will be attached to the ALB"
}

variable "container_port" {
  description = "port the container is listening on"
  default     = 80
}

variable "deployment_maximum_percent" {
  description = "The maximum percent of desired tasks that are allowed during a deployment"
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "The minimum percent of desired tasks that must remain healthy during a deplyment"
  default     = 100
}

variable "desired_count" {
  description = "Desired count of the ECS task"
  default     = 1
}

variable "log_groups" {
  description = "Log groups that will be created in CloudWatch Logs"
  type        = list(string)
}

variable "service_name" {
  description = "Name of the ecs service"
  default     = "svc"
}

variable "scheduler_name" {
  description = "Name of the ecs service"
  default     = "sch"
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "aws_region" {}

variable "task_template" {}

#variable "scheduler_template" {}

variable "max_containers_count" {}

variable "aws_iam_role_arn" {}
