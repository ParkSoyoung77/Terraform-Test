output "bucket_id" {
    value = aws_s3_bucket.std17_s3_bucket.id
}

output "bucket_arn" {
    value = aws_s3_bucket.std17_s3_bucket.arn
}

output "bucket2_id" {
    value = aws_s3_bucket.std17_s3_bucket2.id
}

output "bucket2_arn" {
    value = aws_s3_bucket.std17_s3_bucket2.arn
}

output "bucket3_id" {
    value = aws_s3_bucket.std17_s3_bucket3.id
}

output "bucket3_arn" {
    value = aws_s3_bucket.std17_s3_bucket3.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.std17_cdn.domain_name
}