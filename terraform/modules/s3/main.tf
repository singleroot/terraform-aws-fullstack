# S3 bucket for static file hosting
resource "aws_s3_bucket" "static" {
  bucket = "${var.environment}-static-${var.account_id}"  # must be globally unique
  tags   = { Environment = var.environment }
}

# Block all direct public access — CloudFront will be the ONLY entry point
resource "aws_s3_bucket_public_access_block" "static" {
  bucket                  = aws_s3_bucket.static.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Origin Access Control — secure connection between CF and S3
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${var.environment}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# The CloudFront distribution — your CDN
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"  # only US/EU/Canada edges (cheapest)

  origin {
    domain_name              = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"  # force HTTPS

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true  # free SSL certificate!
  }

  tags = { Environment = var.environment }
}

# Bucket policy — only CloudFront can read from S3
resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFrontOnly"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.static.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
        }
      }
    }]
  })
}