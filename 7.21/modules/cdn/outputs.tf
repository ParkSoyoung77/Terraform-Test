output "distribution_id" {
    value = aws_cloudfront_distribution.std17_cdn.id
}

output "distribution_domain_name" {
    value = aws_cloudfront_distribution.std17_cdn.domain_name
}

output "cdn_url" {
    value = "https://${var.domain_name}"
}