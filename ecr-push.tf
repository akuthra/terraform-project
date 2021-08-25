resource "null_resource" "push_acs_image" {
  triggers = {
    version = var.app_image_version
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/pull_push.sh packages.syncron.team:6666/${var.app_ecr_repo}:${var.app_image_version} ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.app_ecr_repo}:${var.app_image_version}"
  }
}
