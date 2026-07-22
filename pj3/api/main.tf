# ==================================================================
# HTTP API 생성
# ==================================================================
resource "aws_apigatewayv2_api" "std17_report_api" {
    name          = var.api_name
    protocol_type = "HTTP"
}

# ==================================================================
# 통합 1: /html1 -> S3
# ==================================================================
resource "aws_apigatewayv2_integration" "html1_integration" {
    api_id                 = aws_apigatewayv2_api.std17_report_api.id
    integration_type       = "HTTP_PROXY"
    integration_method     = "ANY"
    integration_uri        = "http://${var.domain_website_endpoint}/html1.html"
    payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "html1_route" {
    api_id    = aws_apigatewayv2_api.std17_report_api.id
    route_key = "GET /html1"
    target    = "integrations/${aws_apigatewayv2_integration.html1_integration.id}"
}

# ==================================================================
# 통합 2: /html2 -> S3
# ==================================================================
resource "aws_apigatewayv2_integration" "html2_integration" {
    api_id                 = aws_apigatewayv2_api.std17_report_api.id
    integration_type       = "HTTP_PROXY"
    integration_method     = "ANY"
    integration_uri        = "http://${var.domain_website_endpoint}/html2.html"
    payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "html2_route" {
    api_id    = aws_apigatewayv2_api.std17_report_api.id
    route_key = "GET /html2"
    target    = "integrations/${aws_apigatewayv2_integration.html2_integration.id}"
}

# ==================================================================
# 스테이지: $default (auto_deploy)
# ==================================================================
resource "aws_apigatewayv2_stage" "default" {
    api_id      = aws_apigatewayv2_api.std17_report_api.id
    name        = "$default"
    auto_deploy = true
}