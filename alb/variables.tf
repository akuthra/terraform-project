variable "backend_port" {
  description = "The port the service on the EC2 instances listen on."
  default     = 80
}

variable "backend_protocol" {
  description = "The protocol the backend service speaks. Options: HTTP, HTTPS, TCP, SSL (secure tcp)."
  default     = "HTTP"
}

variable "backend_sg_id" {
  description = "Security group ID of the instance to add rule to allow incoming tcp from ALB"
}

variable "certificate_arn" {
  description = "ARN for SSL/TLS certificate"
  default     = "cert_arn"
}

variable "private_zone" {
  description = "Private Route 53 zone (default=false)"
  default     = false
}

variable "name" {
  description = "Base name to use for resources in the module"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID to create cluster in"
}

variable "vpc_subnets" {
  description = "List of subnets to put instances in"
  type        = list(string)
}

variable "aws_region" {}

variable "aws_account_name" {}

variable "idle_timeout" {
  default = 180
}
