output "bucket_id" {
    value = aws_s3_bucket.std17_s3_bucket.id
}

output "bucket_arn" {
    value = aws_s3_bucket.std17_s3_bucket.arn
}

output "website_endpoint" {
    value = aws_s3_bucket_website_configuration.std17_s3_bucket_web_config.website_endpoint
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.std17_cdn.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.std17_cdn.id
}

output "cloudfront_oac_id" {
  value = aws_cloudfront_origin_access_control.std17_s3_oac.id
}