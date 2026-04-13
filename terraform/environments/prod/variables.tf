variable "environment" {
  type    = string
  default = "prod"
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "create_rds" {
  type    = bool
  default = false
}
variable "db_name" {
  type    = string
  default = "appdb"
}
variable "db_username" {
  type    = string
  default = "dbadmin"
}
variable "db_password" {
  type      = string
  sensitive = true
}
