
variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket for Terraform backend state"
  type        = string
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to deploy subnets"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
}

variable "node_group_name" {
  description = "Name for the EKS node group"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of nodes in the node group"
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of nodes in the node group"
  type        = number
}

variable "min_capacity" {
  description = "Minimum number of nodes in the node group"
  type        = number
}

variable "instance_types" {
  description = "EC2 instance types for the node group"
  type        = list(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)


}

variable "cluster_role_name" {}
variable "node_role_name" {}

