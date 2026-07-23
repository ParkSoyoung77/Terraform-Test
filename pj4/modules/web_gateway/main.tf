resource "aws_api_gateway_rest_api" "std17_web_api" {
  name = "std17-web-api"
}

# --- / (메인 페이지) -> ALB 프록시 ---
resource "aws_api_gateway_method" "root_any" {
  rest_api_id   = aws_api_gateway_rest_api.std17_web_api.id
  resource_id   = aws_api_gateway_rest_api.std17_web_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_alb" {
  rest_api_id             = aws_api_gateway_rest_api.std17_web_api.id
  resource_id              = aws_api_gateway_rest_api.std17_web_api.root_resource_id
  http_method               = aws_api_gateway_method.root_any.http_method
  type                       = "HTTP_PROXY"
  integration_http_method   = "ANY"
  uri = "http://${var.alb_dns_name}/"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.std17_web_api.id
  parent_id   = aws_api_gateway_rest_api.std17_web_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.std17_web_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_alb" {
  rest_api_id             = aws_api_gateway_rest_api.std17_web_api.id
  resource_id              = aws_api_gateway_resource.proxy.id
  http_method               = aws_api_gateway_method.proxy_any.http_method
  type                       = "HTTP_PROXY"
  integration_http_method   = "ANY"
  uri = "http://${var.alb_dns_name}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# --- /ubuntu -> S3 프록시 ---
resource "aws_api_gateway_resource" "ubuntu" {
  rest_api_id = aws_api_gateway_rest_api.std17_web_api.id
  parent_id   = aws_api_gateway_rest_api.std17_web_api.root_resource_id
  path_part   = "ubuntu"
}

resource "aws_api_gateway_method" "ubuntu_get" {
  rest_api_id   = aws_api_gateway_rest_api.std17_web_api.id
  resource_id   = aws_api_gateway_resource.ubuntu.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ubuntu_s3" {
  rest_api_id             = aws_api_gateway_rest_api.std17_web_api.id
  resource_id              = aws_api_gateway_resource.ubuntu.id
  http_method               = aws_api_gateway_method.ubuntu_get.http_method
  type                       = "HTTP_PROXY"
  integration_http_method   = "GET"
  uri = "http://${var.ubuntu_website_endpoint}/ubuntu.html"
}

# --- /mysql -> S3 프록시 ---
resource "aws_api_gateway_resource" "mysql" {
  rest_api_id = aws_api_gateway_rest_api.std17_web_api.id
  parent_id   = aws_api_gateway_rest_api.std17_web_api.root_resource_id
  path_part   = "mysql"
}

resource "aws_api_gateway_method" "mysql_get" {
  rest_api_id   = aws_api_gateway_rest_api.std17_web_api.id
  resource_id   = aws_api_gateway_resource.mysql.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "mysql_s3" {
  rest_api_id             = aws_api_gateway_rest_api.std17_web_api.id
  resource_id              = aws_api_gateway_resource.mysql.id
  http_method               = aws_api_gateway_method.mysql_get.http_method
  type                       = "HTTP_PROXY"
  integration_http_method   = "GET"
  uri = "http://${var.mysql_website_endpoint}/mysql.html"
}

# --- /docker -> S3 프록시 ---
resource "aws_api_gateway_resource" "docker" {
  rest_api_id = aws_api_gateway_rest_api.std17_web_api.id
  parent_id   = aws_api_gateway_rest_api.std17_web_api.root_resource_id
  path_part   = "docker"
}

resource "aws_api_gateway_method" "docker_get" {
  rest_api_id   = aws_api_gateway_rest_api.std17_web_api.id
  resource_id   = aws_api_gateway_resource.docker.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "docker_s3" {
  rest_api_id             = aws_api_gateway_rest_api.std17_web_api.id
  resource_id              = aws_api_gateway_resource.docker.id
  http_method               = aws_api_gateway_method.docker_get.http_method
  type                       = "HTTP_PROXY"
  integration_http_method   = "GET"
  uri = "http://${var.docker_website_endpoint}/docker.html"
}

# --- 배포/스테이지 ---
resource "aws_api_gateway_deployment" "std17_web_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.std17_web_api.id

  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_integration.root_alb.id,
      aws_api_gateway_integration.proxy_alb.id,
      aws_api_gateway_integration.ubuntu_s3.id,
      aws_api_gateway_integration.mysql_s3.id,
      aws_api_gateway_integration.docker_s3.id,
    ]))
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_stage" "std17_web_api_stage" {
  deployment_id = aws_api_gateway_deployment.std17_web_api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.std17_web_api.id
  stage_name    = "prod"
}

# --- 사용자 지정 도메인: www.sy99.cloud ---
resource "aws_api_gateway_domain_name" "std17_web_domain" {
  domain_name              = var.web_domain_name
  regional_certificate_arn = var.acm_certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "std17_web_mapping" {
  api_id      = aws_api_gateway_rest_api.std17_web_api.id
  stage_name  = aws_api_gateway_stage.std17_web_api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.std17_web_domain.domain_name
}

resource "aws_route53_record" "std17_web_alias" {
  zone_id = var.hosted_zone_id
  name    = var.web_domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.std17_web_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.std17_web_domain.regional_zone_id
    evaluate_target_health = false
  }
}