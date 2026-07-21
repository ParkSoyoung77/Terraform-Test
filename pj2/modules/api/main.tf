resource "aws_apigatewayv2_api" "std17_http_api" {
    name            = "std17-http-api"
    protocol_type   = "HTTP"
    ip_address_type = "ipv4"
}

resource "aws_apigatewayv2_integration" "std17_lambda_integration" {
    api_id                 = aws_apigatewayv2_api.std17_http_api.id
    integration_type       = "AWS_PROXY"
    integration_method     = "POST"
    integration_uri        = aws_lambda_function.std17_db_check.invoke_arn
    payload_format_version = "2.0"
}

# www.sy99.cloud/api (CloudFront가 이 경로를 이 API로 전달)
resource "aws_apigatewayv2_route" "std17_api_route" {
    api_id    = aws_apigatewayv2_api.std17_http_api.id
    route_key = "ANY /api"
    target    = "integrations/${aws_apigatewayv2_integration.std17_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "std17_api_proxy_route" {
    api_id    = aws_apigatewayv2_api.std17_http_api.id
    route_key = "ANY /api/{proxy+}"
    target    = "integrations/${aws_apigatewayv2_integration.std17_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "std17_default_stage" {
    api_id      = aws_apigatewayv2_api.std17_http_api.id
    name        = "$default"
    auto_deploy = true
}

resource "aws_lambda_permission" "std17_apigw_lambda" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.std17_db_check.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_apigatewayv2_api.std17_http_api.execution_arn}/*/*"
}