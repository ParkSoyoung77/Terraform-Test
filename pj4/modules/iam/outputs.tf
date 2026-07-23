output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.std17_s3_role.name
}

output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.std17_s3_role.arn
}

output "instance_profile_name" {
  description = "IAM instance profile name (compute 모듈에서 참조)"
  value       = aws_iam_instance_profile.std17_s3_profile.name
}

output "rds_proxy_role_arn" {
  description = "RDS Proxy IAM Role ARN (database 모듈에서 참조)"
  value       = aws_iam_role.std17_rds_proxy_role.arn
}

output "rds_proxy_role_name" {
  description = "RDS Proxy IAM Role 이름 (database 모듈에서 시크릿 정책 부착용으로 참조)"
  value       = aws_iam_role.std17_rds_proxy_role.name
}

output "lambda_role_arn" {
  description = "Lambda IAM Role ARN (api 모듈에서 참조)"
  value       = aws_iam_role.std17_lambda_role.arn
}

output "lambda_role_name" {
  description = "Lambda IAM Role 이름 (api 모듈에서 시크릿 정책 부착용으로 참조)"
  value       = aws_iam_role.std17_lambda_role.name
}