# ==================================================================
# API Gateway REST API (뼈대만 — 백엔드 미정)
# ==================================================================
resource "aws_api_gateway_rest_api" "std17_rest_api" {
    name        = "std17-api"
    description = "std17 REST API"

    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

# 헬스체크용 임시 MOCK 메서드 (루트 경로)
# 백엔드 정해지면 이 블록을 실제 integration으로 교체하면 됩니다.
resource "aws_api_gateway_method" "std17_root_get" {
    rest_api_id   = aws_api_gateway_rest_api.std17_rest_api.id
    resource_id   = aws_api_gateway_rest_api.std17_rest_api.root_resource_id
    http_method   = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "std17_root_mock" {
    rest_api_id = aws_api_gateway_rest_api.std17_rest_api.id
    resource_id = aws_api_gateway_rest_api.std17_rest_api.root_resource_id
    http_method = aws_api_gateway_method.std17_root_get.http_method
    type        = "MOCK"

    request_templates = {
        "application/json" = jsonencode({ statusCode = 200 })
    }
}

resource "aws_api_gateway_method_response" "std17_root_200" {
    rest_api_id = aws_api_gateway_rest_api.std17_rest_api.id
    resource_id = aws_api_gateway_rest_api.std17_rest_api.root_resource_id
    http_method = aws_api_gateway_method.std17_root_get.http_method
    status_code = "200"
}

resource "aws_api_gateway_integration_response" "std17_root_mock_response" {
    rest_api_id = aws_api_gateway_rest_api.std17_rest_api.id
    resource_id = aws_api_gateway_rest_api.std17_rest_api.root_resource_id
    http_method = aws_api_gateway_method.std17_root_get.http_method
    status_code = aws_api_gateway_method_response.std17_root_200.status_code

    response_templates = {
        "application/json" = jsonencode({ message = "std17 API Gateway is alive" })
    }
}

# ==================================================================
# 배포 / 스테이지
# ==================================================================
resource "aws_api_gateway_deployment" "std17_deployment" {
    rest_api_id = aws_api_gateway_rest_api.std17_rest_api.id

    triggers = {
        redeployment = sha1(jsonencode([
            aws_api_gateway_method.std17_root_get.id,
            aws_api_gateway_integration.std17_root_mock.id,
        ]))
    }

    lifecycle {
        create_before_destroy = true
    }

    depends_on = [
        aws_api_gateway_integration.std17_root_mock,
        aws_api_gateway_integration_response.std17_root_mock_response,
    ]
}

resource "aws_api_gateway_stage" "std17_stage" {
    deployment_id = aws_api_gateway_deployment.std17_deployment.id
    rest_api_id   = aws_api_gateway_rest_api.std17_rest_api.id
    stage_name    = var.stage_name
}

# ==================================================================
# 커스텀 도메인 (콘솔에서 발급한 기존 ACM 인증서 참조)
# ==================================================================
resource "aws_api_gateway_domain_name" "std17_apigw_domain" {
    domain_name              = var.custom_domain_name
    regional_certificate_arn = var.acm_certificate_arn   # data 참조 → 변수로 직접 받기

    endpoint_configuration {
        types           = ["REGIONAL"]
        ip_address_type = "ipv4"
    }

    security_policy = "TLS_1_2"

    tags = { Name = "std17-apigw-domain" }
}

resource "aws_api_gateway_base_path_mapping" "std17_apigw_mapping" {
    api_id      = aws_api_gateway_rest_api.std17_rest_api.id
    stage_name  = aws_api_gateway_stage.std17_stage.stage_name
    domain_name = aws_api_gateway_domain_name.std17_apigw_domain.domain_name
    # base_path 미지정 → apigw.sy99.cloud/ 로 바로 매핑 (API 매핑 전용)
}

# ==================================================================
# Route53 Alias
# ==================================================================
resource "aws_route53_record" "std17_apigw_alias" {
    zone_id = var.hosted_zone_id
    name    = var.custom_domain_name
    type    = "A"

    alias {
        name                   = aws_api_gateway_domain_name.std17_apigw_domain.regional_domain_name
        zone_id                = aws_api_gateway_domain_name.std17_apigw_domain.regional_zone_id
        evaluate_target_health = true
    }
}