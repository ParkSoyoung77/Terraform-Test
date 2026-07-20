resource "aws_cloudfront_origin_access_control" "std17_s3_oac" {
  name                              = "std17-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "std17_cdn" {
  # 1번 버킷 (index.html)
  origin {
    domain_name              = module.storage.bucket_regional_domain_name
    origin_id                = "std17-s3-origin-1"
    origin_access_control_id = aws_cloudfront_origin_access_control.std17_s3_oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  # 2번 버킷 (about.html)
  origin {
    domain_name              = module.storage.bucket2_regional_domain_name
    origin_id                = "std17-s3-origin-2"
    origin_access_control_id = aws_cloudfront_origin_access_control.std17_s3_oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  # 3번 버킷 (services.html)
  origin {
    domain_name              = module.storage.bucket3_regional_domain_name
    origin_id                = "std17-s3-origin-3"
    origin_access_control_id = aws_cloudfront_origin_access_control.std17_s3_oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  # 4번 오리진 (API Gateway → Lambda DB Check)
  origin {
    domain_name = replace(module.api.api_endpoint, "https://", "")
    origin_id   = "std17-apigw-origin"

    custom_origin_config {
      http_port                = 80
      https_port                = 443
      origin_protocol_policy    = "https-only"
      origin_ssl_protocols      = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # 기본 경로 -> 1번 버킷
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "std17-s3-origin-1"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # /about.html -> 2번 버킷
  ordered_cache_behavior {
    path_pattern           = "about.html"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "std17-s3-origin-2"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # /services.html -> 3번 버킷
  ordered_cache_behavior {
    path_pattern           = "services.html"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "std17-s3-origin-3"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # /lambda -> API Gateway (Lambda DB 연결 테스트)
  ordered_cache_behavior {
    path_pattern           = "lambda"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "std17-apigw-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

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

  tags = { Name = "std17-cloudfront" }
}

# ---------------- S3 버킷 정책 (CloudFront OAC 허용) ----------------

resource "aws_s3_bucket_policy" "std17_s3_bucket_policy" {
  bucket = module.storage.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${module.storage.bucket_arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.std17_cdn.arn
        }
      }
    }]
  })
}

resource "aws_s3_bucket_policy" "std17_s3_bucket2_policy" {
  bucket = module.storage.bucket2_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${module.storage.bucket2_arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.std17_cdn.arn
        }
      }
    }]
  })
}

resource "aws_s3_bucket_policy" "std17_s3_bucket3_policy" {
  bucket = module.storage.bucket3_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${module.storage.bucket3_arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.std17_cdn.arn
        }
      }
    }]
  })
}
