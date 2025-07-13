resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = var.subnet_ids # Will be public subnets
    endpoint_private_access = false
    endpoint_public_access  = true
  }

  tags = var.tags
}
