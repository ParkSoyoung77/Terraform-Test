output "bucket_id" {
    value = aws_s3_bucket.std17_s3_bucket.id
}

output "bucket_arn" {
    value = aws_s3_bucket.std17_s3_bucket.arn
}

output "bucket_regional_domain_name" {
    description = "CloudFront OAC origin용 REST 엔드포인트 도메인"
    value       = aws_s3_bucket.std17_s3_bucket.bucket_regional_domain_name
}