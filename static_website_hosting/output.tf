output "s3_bucket_name" {
  description = "The name of the S3 bucket."
  value       = aws_s3_bucket.website_bucket.bucket
}

output "s3_bucket_website_endpoint" {
  description = "The direct S3 website endpoint (Note: This is HTTP only)."
  value       = aws_s3_bucket_website_configuration.website
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_domain_name" {
  description = "The auto-generated CloudFront domain name (e.g., d111111abcdef8.cloudfront.net)."
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "website_url" {
  description = "The custom domain URL for the website."
  value       = "https://${var.domain_name}"
}

output "acm_certificate_status" {
  description = "The current status of the SSL certificate."
  value       = aws_acm_certificate.cert.status
}