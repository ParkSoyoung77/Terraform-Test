# resource "aws_cloudfront_distribution" "std17_cdn" {
#     enabled             = true
#     is_ipv6_enabled     = true
#     default_root_object = "index.html"
#     aliases             = [var.domain_name]
#     price_class         = var.price_class

#     origin {
#         domain_name = var.s3_bucket_website_endpoint
#         origin_id   = "std17-s3-website-origin"

#         # S3 웹사이트 엔드포인트는 HTTPS 미지원 → http-only만 가능
#         custom_origin_config {
#             http_port              = 80
#             https_port              = 443
#             origin_protocol_policy = "http-only"
#             origin_ssl_protocols   = ["TLSv1.2"]
#         }
#     }

#     default_cache_behavior {
#         allowed_methods        = ["GET", "HEAD"]
#         cached_methods          = ["GET", "HEAD"]
#         target_origin_id        = "std17-s3-website-origin"
#         viewer_protocol_policy = "allow-all"   # 보안 비활성화 — HTTP도 그대로 허용

#         forwarded_values {
#             query_string = false
#             cookies {
#                 forward = "none"
#             }
#         }

#         min_ttl     = 0
#         default_ttl = 3600
#         max_ttl     = 86400
#     }

#     restrictions {
#         geo_restriction {
#             restriction_type = "none"
#         }
#     }

#     viewer_certificate {
#         acm_certificate_arn      = var.acm_certificate_arn
#         ssl_support_method       = "sni-only"
#         minimum_protocol_version = "TLSv1"     # 보안 비활성화 — 최저 호환 버전 허용
#     }

#     tags = { Name = "std17-cdn" }
# }

# resource "aws_route53_record" "std17_cdn_alias" {
#     zone_id = var.hosted_zone_id
#     name    = var.domain_name
#     type    = "A"

#     alias {
#         name                   = aws_cloudfront_distribution.std17_cdn.domain_name
#         zone_id                = "Z2FDTNDATAQYW2"   # CloudFront 전용 고정 zone id (모든 배포 공통)
#         evaluate_target_health = false
#     }
# }