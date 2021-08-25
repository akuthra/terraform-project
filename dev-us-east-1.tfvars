aws_account_id     = "801354763506"
aws_account_name   = "platform-dev"
aws_region         = "us-east-1"
stage              = "dev"
repository_name    = "acs-dev-config-store"
vpc_id             = "vpc-00050541de593596b"
private_subnet_ids = ["subnet-01c50ae63b645927b", "subnet-0b12ba0ff16aec3d5"]


performance_insights_retention_period = 7
security_group_ids                    = ["sg-0b3cdd701e2a774b9"]

app_ecr_repo      = "syncron/acs"
app_image_version = "21.1.0.0"
service-image-hash = "sha256:3cc8a79183e03e5788447e78d2f47ee4925f021d837c6a54bbc28c16ea34b380"
ce_max_vcpus      = "4"
ce_min_vcpus      = "2"
containers_count  = "4"
desired_instance_count = "2"
ec2-instance-types  = ["t2.medium", "t2.micro"]
idle_timeout      = "300"
max_containers_count  = "6"
max_instance_count  = "3"
min_instance_count  = "1"
app_instance_type  = "t2.medium"
aws_iam_role_arn  = "arn:aws:iam::801354763506:role/a3m-ec2-ecs-role-eu-west-1"



# Tags
tags = {
  cost_category   = "internal-product"
  environmenttype = "dev"
  product         = "cloud-platfor"
  application     = "acs"
  origin          = "terraform"
  owner           = "mahgow"
  tenant          = "syncron-rnd-cloud-platform"
}