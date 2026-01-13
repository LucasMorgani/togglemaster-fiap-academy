# Variable for the VPC to be used for the RDS
variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (name tag)"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to be used to RDS create"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR from VPC to be used to rds security group ingress"
}

variable "private_subnet_1a" {
  type        = string
  description = "Subnet to create RDS subnet-group"
}

variable "private_subnet_1b" {
  type        = string
  description = "Subnet to create RDS subnet-group"
}

variable "db_user" {
  type        = string
  description = "User to RDS Postgres"
}

variable "db_password" {
  type        = string
  description = "Password to RDS Postgres"
}