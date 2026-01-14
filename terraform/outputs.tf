output "cloudfront_distribution_id" {
  description = "Cloudfront distribution id"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_domain_name" {
  description = "Cloudfront distribution domain name"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_status" {
  description = "Cloudfront distribution status"
  value       = aws_cloudfront_distribution.s3_distribution.status
}

output "s3_bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = aws_s3_bucket.default.bucket_domain_name
}

output "deployed_domain" {
  description = "Route 53 record domain for the deploy"
  value       = aws_route53_record.cloudfront_web_record.name
}
