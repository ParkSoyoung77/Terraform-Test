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