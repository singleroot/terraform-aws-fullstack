# VPC = your private network in AWS
# Like buying a plot of land — nothing can be built without it
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr      # IP range: 10.0.0.0/16 = 65,536 addresses
  enable_dns_hostnames = true               # lets EC2 get DNS names
  enable_dns_support   = true

  tags = { Name = "${var.environment}-vpc" }
}

# Internet Gateway = the door between your VPC and the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-igw" }
}

# Public subnets — EC2 and ALB live here (internet-facing)
resource "aws_subnet" "public" {
  count             = 2                    # 2 subnets for redundancy
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true           # EC2 gets a public IP

  tags = { Name = "${var.environment}-public-${count.index}" }
}

# Private subnets — RDS lives here (no direct internet access)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "${var.environment}-private-${count.index}" }
}

# Route table — tells traffic HOW to get to the internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"              # all traffic...
    gateway_id = aws_internet_gateway.main.id  # ...goes through the internet gateway
  }
  tags = { Name = "${var.environment}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group for EC2 — controls what traffic is allowed
resource "aws_security_group" "ec2" {
  name        = "${var.environment}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]           # allow HTTP from anywhere
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]           # allow HTTPS from anywhere
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]           # SSH (restrict to your IP in production!)
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]           # allow all outbound traffic
  }
}

# Security Group for RDS — only EC2 can talk to the database
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS-only allow EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]  # ONLY from EC2!
  }
}

data "aws_availability_zones" "available" { state = "available" }
