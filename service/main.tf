terraform {
  required_version = ">= 0.12"
}

resource "aws_cloudwatch_log_group" "svc" {
  count = length(var.log_groups)
  name  = element(var.log_groups, count.index)
  #tags  = merge(var.tags, map("Name", format("%s", var.service_name)))
}

resource "aws_ecs_task_definition" "service-task-defination" {
  container_definitions = var.task_template
  family                = var.service_name
  task_role_arn         = var.aws_iam_role_arn
}
resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.cluster
  task_definition = aws_ecs_task_definition.service-task-defination.arn
  desired_count   = var.desired_count
  iam_role        = var.aws_iam_role_arn

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  depends_on = [aws_ecs_service.service]

  max_capacity       = var.max_containers_count
  min_capacity       = var.desired_count
  resource_id        = "service/syncron-price-${var.service_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_request_targettracking" {
  depends_on         = [aws_appautoscaling_target.ecs_target]
  name               = "ALBRequestCountPerTarget:${aws_appautoscaling_target.ecs_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${var.alb_arn_suffix}/${var.target_group_suffix}"
    }
    target_value = 20000
  }
}

resource "aws_autoscaling_policy" "ecs_cluster_request_count_scaling" {
  name = "ecs_cluster_request_count_scaling"

  autoscaling_group_name = var.asg_name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "TargetGroup"
        value = var.target_group_suffix
      }
      unit = "Count"

      metric_name = "RequestCountPerTarget"
      namespace   = "AWS/ApplicationELB"
      statistic   = "Sum"
    }

    target_value = "20000"
  }

}
