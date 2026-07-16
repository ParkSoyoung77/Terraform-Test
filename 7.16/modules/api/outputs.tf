output "api_endpoint" {
  value = aws_apigatewayv2_api.std17_http_api.api_endpoint
}

# output "api_invoke_url" {
#   value = aws_api_gateway_stage.std17_api_stage.invoke_url
# }

# output "api_stage_name" {
#   value = aws_api_gateway_stage.std17_api_stage.stage_name
# }