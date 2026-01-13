# Variable for the CIDR BLOCK to be used for the VPC
variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (name tag)"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
}


# Cluster name
variable "cluster_name" {
  type        = string
  description = "Cluster name to be used for integrate mng to cluster"
}


# Private subnets to create the MNG. From Network Module
variable "private_subnet_1a" {
  type        = string
  description = "Subnet to create EKS Manage Node Group AZ-1a"
}

variable "private_subnet_1b" {
  type        = string
  description = "Subnet to create EKS Manage Node Group AZ-1b"
}

variable "eks_cluster_sg" {
  type        = string
  description = "Cluster SG to ingress rules"
}

