# Variable for the CIDR BLOCK to be used for the VPC
variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (name tag)"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
}


# Public subnets to create the cluster. From Network Module
variable "public_subnet_1a" {
  description = "Subnet to create EKS cluster AZ-1a"
}

variable "public_subnet_1b" {
  type        = string
  description = "Subnet to create EKS cluster AZ-1b"
}