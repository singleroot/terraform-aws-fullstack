# Look up the latest Amazon Linux 2023 AMI automatically
# This is a data block — reads existing AWS info, creates nothing
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# The EC2 instance — your virtual machine
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type   # t2.micro = free tier
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  # user_data runs automatically on first boot
  # This installs nginx and creates a simple test page
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo '<h1>${var.environment} Server Running!</h1>' > /usr/share/nginx/html/index.html
    echo '<p>EC2 Instance: '$(hostname)'</p>' >> /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name        = "${var.environment}-app-server"
    Environment = var.environment
  }
}

# IAM Role — gives EC2 permission to talk to S3
resource "aws_iam_role" "ec2" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name
}
