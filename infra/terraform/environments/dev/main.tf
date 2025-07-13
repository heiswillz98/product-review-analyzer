
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  name                 = var.name_prefix
  tags                 = var.tags

}

module "eks" {
  source = "../../modules/eks"

  cluster_name     = var.cluster_name
  subnet_ids       = module.vpc.public_subnet_ids
  cluster_role_arn = module.iam.cluster_role_arn
  tags             = var.tags
}

module "node_group" {
  source = "../../modules/node_group"

  cluster_name     = module.eks.cluster_name
  node_group_name  = var.node_group_name
  subnet_ids       = module.vpc.public_subnet_ids
  desired_capacity = var.desired_capacity
  max_capacity     = var.max_capacity
  min_capacity     = var.min_capacity
  instance_types   = var.instance_types
  node_role_arn    = module.iam.node_role_arn
  tags             = var.tags

  depends_on = [module.eks]
}

module "iam" {
  source = "../../modules/iam"

  cluster_role_name = var.cluster_role_name
  node_role_name    = var.node_role_name
}
