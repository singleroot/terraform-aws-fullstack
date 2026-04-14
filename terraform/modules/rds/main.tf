# Subnet group — tells RDS which subnets it can use
# Must span 2 availability zones (AWS requirement)
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "${var.environment}-db-subnet-group" }
}

# The actual database
resource "aws_db_instance" "main" {
  identifier        = "${var.environment}-postgres"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = var.instance_class    # db.t3.micro = free tier
  allocated_storage = var.allocated_storage # 20GB = free tier

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password              # comes from GitHub Secrets

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  # Free tier settings
  backup_retention_period = 1             # keep backups for 7 days
  skip_final_snapshot     = true          # for dev/staging — set false for prod!
  multi_az                = false         # multi-az costs money
  publicly_accessible     = false         # NEVER expose DB to internet
  storage_encrypted       = true          # encrypt at rest (free)

  tags = { Environment = var.environment }
}
