resource "aws_api_gateway_rest_api" "std17_lambda_api" {
  name = "std17-lambda-api"
}

resource "aws_api_gateway_method" "root_any" {
  rest_api_id   = aws_api_gateway_rest_api.std17_lambda_api.id
  resource_id   = aws_api_gateway_rest_api.std17_lambda_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.std17_lambda_api.id
  resource_id              = aws_api_gateway_rest_api.std17_lambda_api.root_resource_id
  http_method               = aws_api_gateway_method.root_any.http_method
  integration_http_method   = "POST"
  type                       = "AWS_PROXY"
  uri = aws_lambda_function.std17_db_check.invoke_arn
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.std17_lambda_api.id
  parent_id   = aws_api_gateway_rest_api.std17_lambda_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.std17_lambda_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.std17_lambda_api.id
  resource_id              = aws_api_gateway_resource.proxy.id
  http_method               = aws_api_gateway_method.proxy_any.http_method
  integration_http_method   = "POST"
  type                       = "AWS_PROXY"
  uri = aws_lambda_function.std17_db_check.invoke_arn
}

resource "aws_api_gateway_deployment" "std17_lambda_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.std17_lambda_api.id

  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_integration.root_lambda.id,
      aws_api_gateway_integration.proxy_lambda.id,
    ]))
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_stage" "std17_lambda_api_stage" {
  deployment_id = aws_api_gateway_deployment.std17_lambda_api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.std17_lambda_api.id
  stage_name    = "prod"
}

resource "aws_lambda_permission" "std17_apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.std17_db_check.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.std17_lambda_api.execution_arn}/*/*"
}

# ==================================================================
# 사용자 지정 도메인: api.sy99.cloud
# ==================================================================
resource "aws_api_gateway_domain_name" "std17_api_domain" {
  domain_name              = var.api_domain_name
  regional_certificate_arn = var.acm_certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "std17_api_mapping" {
  api_id      = aws_api_gateway_rest_api.std17_lambda_api.id
  stage_name  = aws_api_gateway_stage.std17_lambda_api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.std17_api_domain.domain_name
}

resource "aws_route53_record" "std17_api_alias" {
  zone_id = var.hosted_zone_id
  name    = var.api_domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.std17_api_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.std17_api_domain.regional_zone_id
    evaluate_target_health = false
  }
}