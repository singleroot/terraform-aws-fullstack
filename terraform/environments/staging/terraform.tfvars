environment   = "staging"
aws_region    = "us-east-1"
vpc_cidr      = "10.1.0.0/16"
instance_type = "t2.micro"
create_rds    = false # dev shares RDS — saves free tier
db_name       = "appdb"
db_username   = "dbadmin"
# db_password comes from GitHub Secrets — NEVER put it here
