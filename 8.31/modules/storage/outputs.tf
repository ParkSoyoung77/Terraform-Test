output "bucket_id" {
  description = "메인 S3 버킷 ID (index.html, EC2 user_data 동기화용)"
  value       = aws_s3_bucket.std17_s3_bucket.id
}

output "bucket_arn" {
  description = "메인 S3 버킷 ARN"
  value       = aws_s3_bucket.std17_s3_bucket.arn
}

output "bucket1_id" {
  description = "ubuntu.html 버킷 ID"
  value       = aws_s3_bucket.std17_s3_bucket1.id
}

output "bucket1_arn" {
  description = "ubuntu.html 버킷 ARN"
  value       = aws_s3_bucket.std17_s3_bucket1.arn
}

output "bucket2_id" {
  description = "mysql.html 버킷 ID"
  value       = aws_s3_bucket.std17_s3_bucket2.id
}

output "bucket2_arn" {
  description = "mysql.html 버킷 ARN"
  value       = aws_s3_bucket.std17_s3_bucket2.arn
}

output "bucket3_id" {
  description = "docker.html 버킷 ID"
  value       = aws_s3_bucket.std17_s3_bucket3.id
}

output "bucket3_arn" {
  description = "docker.html 버킷 ARN"
  value       = aws_s3_bucket.std17_s3_bucket3.arn
}

output "bucket_regional_domain_name" {
  description = "메인 버킷 리전 도메인 이름"
  value       = aws_s3_bucket.std17_s3_bucket.bucket_regional_domain_name
}

output "bucket1_regional_domain_name" {
  description = "ubuntu 버킷 리전 도메인 이름"
  value       = aws_s3_bucket.std17_s3_bucket1.bucket_regional_domain_name
}

output "bucket2_regional_domain_name" {
  description = "mysql 버킷 리전 도메인 이름"
  value       = aws_s3_bucket.std17_s3_bucket2.bucket_regional_domain_name
}

output "bucket3_regional_domain_name" {
  description = "docker 버킷 리전 도메인 이름"
  value       = aws_s3_bucket.std17_s3_bucket3.bucket_regional_domain_name
}

output "bucket1_website_endpoint" {
  description = "ubuntu 버킷 정적 웹사이트 호스팅 엔드포인트 (API Gateway HTTP_PROXY 대상)"
  value       = aws_s3_bucket_website_configuration.std17_bucket1_website.website_endpoint
}

output "bucket2_website_endpoint" {
  description = "mysql 버킷 정적 웹사이트 호스팅 엔드포인트 (API Gateway HTTP_PROXY 대상)"
  value       = aws_s3_bucket_website_configuration.std17_bucket2_website.website_endpoint
}

output "bucket3_website_endpoint" {
  description = "docker 버킷 정적 웹사이트 호스팅 엔드포인트 (API Gateway HTTP_PROXY 대상)"
  value       = aws_s3_bucket_website_configuration.std17_bucket3_website.website_endpoint
}