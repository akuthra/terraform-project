# AWS
variable "aws_region" {}
variable "aws_account_id" {}

# VPC and subnets ids
variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }

# Service
variable "service-repo-name" {
  default = "syncron/acs-service"
}

variable "app_image_version" {}
variable "app_instance_type" {}
variable "service-image-hash" {}
variable "instance_type" {}
variable "idle_timeout" {}
variable "containers_count" {}
variable "max_containers_count" {}
variable "desired_instance_count" {}
variable "max_instance_count" {}
variable "min_instance_count" {}
variable "app_ecr_repo" {}
variable "aws_iam_role_arn" {}
variable "stage" {}

variable "tags" {
  type = map(string)
}

variable "service-name" {
  default = "acs"
}



variable "prefix" {
  default = "acs"
}

variable "aws_account_name" {
  default = ""
}

variable "ec2-instance-types" {
  type = list(string)
}

// Allowed values for type: EC2 or SPOT. Value EC2 will create on-demand ec2 instances.
variable "ce_instance_type" {
  default = "EC2"
}

variable "ce_max_vcpus" {}
variable "ce_min_vcpus" {}

variable "repository_name" {}
