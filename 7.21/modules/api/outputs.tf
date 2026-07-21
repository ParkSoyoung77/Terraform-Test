output "rest_api_id" {
    value = aws_api_gateway_rest_api.std17_rest_api.id
}

output "root_resource_id" {
    value = aws_api_gateway_rest_api.std17_rest_api.root_resource_id
}

output "stage_name" {
    value = aws_api_gateway_stage.std17_stage.stage_name
}

output "invoke_url" {
    value = aws_api_gateway_stage.std17_stage.invoke_url
}

output "custom_domain_url" {
    value = "https://${aws_api_gateway_domain_name.std17_apigw_domain.domain_name}"
}