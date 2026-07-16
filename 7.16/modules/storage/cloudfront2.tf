resource "aws_cloudfront_distribution" "std17_cdn_api" {
  origin {
    # API Gateway 호출 도메인 (예: xxxxxxxx.execute-api.ap-northeast-2.amazonaws.com)
    domain_name = replace(
      aws_api_gateway_stage.std17_api_stage.invoke_url,
      "/^https?://([^/]*).*/",
      "$1"
    )
    origin_id   = "std17-apigw-origin"

    # API Gateway 스테이지 경로가 origin_path에 포함되어야 함 (예: "/prod")
    origin_path = "/${aws_api_gateway_stage.std17_api_stage.stage_name}"

    custom_origin_config {
      http_port              = 80
      https_port              = 443
      origin_protocol_policy   = "https-only"   # API Gateway는 HTTPS만 지원
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

    enabled         = true
    is_ipv6_enabled = true
    # default_root_object 불필요 (API는 루트 index.html 개념이 없음)

    default_cache_behavior {
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "std17-apigw-origin"
      viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true   # API는 대부분 쿼리스트링을 그대로 넘겨야 함
      headers      = ["Authorization", "Content-Type"]  # 인증/컨텐츠 타입 등 필요한 헤더 지정

      cookies {
        forward = "none"
      }
    }

    # API 응답은 보통 캐싱하지 않는 게 안전 (동적 데이터)
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = { Name = "std17-cloudfront-api" }
}
