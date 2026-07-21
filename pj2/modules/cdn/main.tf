locals {
    api_gateway_domain = "${var.api_id}.execute-api.${var.aws_region}.amazonaws.com"
}

resource "aws_cloudfront_origin_access_control" "std17_oac" {
    name                              = "std17-s3-oac"
    origin_access_control_origin_type = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "std17_cdn" {
    enabled     = true
    comment     = "std17 - www.sy99.cloud"
    aliases     = [var.domain_name]
    price_class = "PriceClass_200"

    origin {
        domain_name = var.alb_dns_name
        origin_id   = "alb-origin"

        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols   = ["TLSv1.2"]
        }
    }

    origin {
        domain_name               = var.s3_bucket_regional_domain_name
        origin_id                 = "s3-origin"
        origin_access_control_id  = aws_cloudfront_origin_access_control.std17_oac.id
    }

    origin {
        domain_name = local.api_gateway_domain
        origin_id   = "apigw-origin"

        custom_origin_config {
            http_port              = 80
            https_port             = 443
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
        }
    }

    # 기본: nginx (요구사항 3)
    default_cache_behavior {
        target_origin_id       = "alb-origin"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods          = ["GET", "HEAD"]

        cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
        origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Managed-AllViewer
    }

    # /index.html -> S3 (요구사항 4)
    ordered_cache_behavior {
        path_pattern           = "/index.html"
        target_origin_id       = "s3-origin"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD", "OPTIONS"]
        cached_methods          = ["GET", "HEAD"]

        cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    }

    # /api, /api/* -> Lambda (요구사항 5, 6)
    ordered_cache_behavior {
        path_pattern            = "/api*"
        target_origin_id        = "apigw-origin"
        viewer_protocol_policy  = "redirect-to-https"
        allowed_methods         = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
        cached_methods          = ["GET", "HEAD"]

        cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
        origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Managed-AllViewer
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    # 요구사항 7: http/https 모두 수신, http -> https 강제 리다이렉트
    viewer_certificate {
        acm_certificate_arn      = var.acm_certificate_arn
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }

    tags = { Name = "std17-cdn" }
}

data "aws_iam_policy_document" "std17_s3_oac_policy" {
    statement {
        sid     = "AllowCloudFrontServicePrincipal"
        effect  = "Allow"
        actions = ["s3:GetObject"]

        principals {
            type        = "Service"
            identifiers = ["cloudfront.amazonaws.com"]
        }

        resources = ["${var.s3_bucket_arn}/*"]

        condition {
            test     = "StringEquals"
            variable = "AWS:SourceArn"
            values   = [aws_cloudfront_distribution.std17_cdn.arn]
        }
    }
}

resource "aws_s3_bucket_policy" "std17_s3_oac_policy" {
    bucket = var.s3_bucket_id
    policy = data.aws_iam_policy_document.std17_s3_oac_policy.json
}

resource "aws_route53_record" "std17_cdn_alias" {
    zone_id = var.hosted_zone_id
    name    = var.domain_name
    type    = "A"

    alias {
        name                   = aws_cloudfront_distribution.std17_cdn.domain_name
        zone_id                = aws_cloudfront_distribution.std17_cdn.hosted_zone_id
        evaluate_target_health = false
    }
}