# Create a VPC for the EKS Cluster
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.cidr_block # Coming from variables.tf
  enable_dns_support   = true           # Needed for EKS to Work
  enable_dns_hostnames = true           # Needed for EKS to Work

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-vpc"
    }
  )
}