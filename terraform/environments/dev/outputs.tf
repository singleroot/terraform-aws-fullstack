output "ec2_public_ip" {
  value       = module.ec2.public_ip
  description = "Public IP of the dev EC2 instance"
}

output "cloudfront_url" {
  value       = "https://${module.s3.cloudfront_domain}"
  description = "CloudFront URL for static files"
}

output "rds_endpoint" {
  value     = var.create_rds ? module.rds[0].endpoint : "N/A (shared RDS)"
  sensitive = false
}
