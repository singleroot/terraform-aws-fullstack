variable "environment"       { type = string }
variable "instance_class"    {
  type = string
  default = "db.t3.micro"
}
variable "allocated_storage" {
  type = number
  default = 20
}
variable "db_name"           { type = string }
variable "db_username"       { type = string }
variable "db_password"       {
  type = string
  sensitive = true
}
variable "private_subnet_ids"{ type = list(string) }
variable "security_group_id" { type = string }