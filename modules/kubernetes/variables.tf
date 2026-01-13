# Variable for the VPC to be used for the RDS
variable "project_name" {
  type        = string
  description = "Project name to be used to name the resources (name tag)"
}

variable "tags" {
  type        = map(any)
  description = "Tags to be added to AWS resources"
}

variable "db_user" {
  type        = string
  description = "User to RDS Postgres"
}

variable "db_password" {
  type        = string
  description = "Password to RDS Postgres"
}

variable "db_auth_endpoint" {
  type        = string
  description = "User to RDS Postgres"
}

#variable "db_auth_name" {
#  type        = string
#  description = "Password to RDS Postgres"
#}

variable "db_flag_endpoint" {
  type        = string
  description = "User to RDS Postgres"
}

#variable "db_flag_name" {
#  type        = string
#  description = "Password to RDS Postgres"
#}

variable "db_targeting_endpoint" {
  type        = string
  description = "User to RDS Postgres"
}

#variable "db_targeting_name" {
#  type        = string
#  description = "Password to RDS Postgres"
#}









