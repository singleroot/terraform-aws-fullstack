# outputs.tf
output "bucket_name"         { value = aws_s3_bucket.static.bucket }
output "cloudfront_domain"   { value = aws_cloudfront_distribution.main.domain_name }
output "cloudfront_id"       { value = aws_cloudfront_distribution.main.id }
