output "listener_https_arns" {
  description = "The ARN of the HTTPS ALB Listener that can be used to add rules"
  value       = module.alb.https_listener_arns
}

output "target_group_arns" {
  description = "ARN of the target group"
  value       = module.alb.target_group_arns
}

output "alb_endpoint" {
  description = "DNS of alb"
  value       = module.alb.this_lb_dns_name
}

output "alb_arn_suffix" {
  value = module.alb.this_lb_arn_suffix
}

output "target_group_suffix" {
  value = module.alb.target_group_arn_suffixes
}
