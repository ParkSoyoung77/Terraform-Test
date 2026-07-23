output "invoke_url" {
  description = "www.sy99.cloud 최종 호출 URL"
  value       = "https://${var.web_domain_name}"
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN (Lambda DB_SECRET_NAME용)"
  value       = aws_secretsmanager_secret.std17_db_secret.arn 
}