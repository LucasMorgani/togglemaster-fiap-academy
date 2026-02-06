# Variable for the CIDR BLOCK to be used for the VPC
variable "cidr_block" {
  type        = string
  description = "Networking CIDR block to be used for the VPC"
}

variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (name tag)"
}

variable "db_user" {
  type        = string
  description = "User to RDS"
}

variable "db_password" {
  type        = string
  description = "Password to RDS"
}