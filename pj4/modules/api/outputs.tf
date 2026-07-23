output "invoke_url" {
  description = "api.sy99.cloud 최종 호출 URL"
  value       = "https://${var.api_domain_name}"
}

output "rest_api_id" {
  description = "Lambda 전용 REST API ID"
  value       = aws_api_gateway_rest_api.std17_lambda_api.id
}