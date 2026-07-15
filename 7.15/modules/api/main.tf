# HTTP API 생성
resource "aws_apigatewayv2_api" "std17_http_api" {
    name          = "std17-http-api"
    protocol_type = "HTTP"
    ip_address_type = "ipv4"
}

# 통합 1: S3 정적 웹사이트 (HTTP 프록시)
resource "aws_apigatewayv2_integration" "std17_s3_integration" {
    api_id                 = aws_apigatewayv2_api.std17_http_api.id
    integration_type       = "HTTP_PROXY"
    integration_method     = "ANY"
    integration_uri        = "${var.s3_website_endpoint}/{proxy}"
    payload_format_version = "1.0"
}

# 통합 2: Lambda
resource "aws_apigatewayv2_integration" "std17_lambda_integration" {
    api_id                 = aws_apigatewayv2_api.std17_http_api.id
    integration_type       = "AWS_PROXY"
    integration_method     = "POST"
    integration_uri        = var.lambda_function_arn
    payload_format_version = "2.0"
}

# 경로 1: GET / -> S3 (루트, index.html)
resource "aws_apigatewayv2_route" "std17_root_route" {
    api_id    = aws_apigatewayv2_api.std17_http_api.id
    route_key = "GET /"
    target    = "integrations/${aws_apigatewayv2_integration.std17_s3_integration.id}"
}

# 경로 1-1: GET /{proxy+} -> S3 (network.html, compute.html, database.html 등 나머지 전부)
resource "aws_apigatewayv2_route" "std17_proxy_route" {
    api_id    = aws_apigatewayv2_api.std17_http_api.id
    route_key = "GET /{proxy+}"
    target    = "integrations/${aws_apigatewayv2_integration.std17_s3_integration.id}"
}

# 경로 2: GET /lambda -> Lambda
resource "aws_apigatewayv2_route" "std17_lambda_route" {
    api_id    = aws_apigatewayv2_api.std17_http_api.id
    route_key = "GET /lambda"
    target    = "integrations/${aws_apigatewayv2_integration.std17_lambda_integration.id}"
}

# 스테이지: $default, 자동 배포
resource "aws_apigatewayv2_stage" "std17_default_stage" {
    api_id      = aws_apigatewayv2_api.std17_http_api.id
    name        = "$default"
    auto_deploy = true
}

# API Gateway가 Lambda를 호출할 수 있도록 권한 부여
resource "aws_lambda_permission" "std17_apigw_lambda" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = var.lambda_function_arn
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_apigatewayv2_api.std17_http_api.execution_arn}/*/*"
}