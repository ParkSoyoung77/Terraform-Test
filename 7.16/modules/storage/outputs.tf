output "bucket_id" {
    value = aws_s3_bucket.std17_s3_bucket.id
}

output "bucket_arn" {
    value = aws_s3_bucket.std17_s3_bucket.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.std17_cdn.domain_name
}

# output "cloudfront_distribution_id" {
#   value = aws_cloudfront_distribution.std17_cdn.id
# }

# output "cloudfront_oac_id" {
#   value = aws_cloudfront_origin_access_control.std17_s3_oac.id
# }

# output "cloudfront_api_domain_name" {
#   value = aws_cloudfront_distribution.std17_cdn_api.domain_name
# }