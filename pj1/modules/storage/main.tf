# html 업로드
locals {
    index_html_path    = var.index_html_path != "" ? var.index_html_path : "${path.module}/files/index.html"
    about_html_path  = var.about_html_path != "" ? var.about_html_path : "${path.module}/files/about.html"
    services_html_path  = var.services_html_path != "" ? var.services_html_path : "${path.module}/files/services.html"
}

# 1번 S3
resource "aws_s3_bucket" "std17_s3_bucket" {
    bucket = var.bucket_name
    tags   = { Name = var.bucket_name }
}

# 퍼블릭 액세스 관리
resource "aws_s3_bucket_public_access_block" "std17_s3_bucket-access" {
    bucket                  = aws_s3_bucket.std17_s3_bucket.id
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
}

# 버킷에 외부 접근에 대한 정책 정의
resource "aws_s3_bucket_policy" "std17_s3_bucket_policy" {
    bucket = aws_s3_bucket.std17_s3_bucket.id

    policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.std17_s3_bucket.arn}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": aws_cloudfront_distribution.std17_cdn.arn
                }
            }
        }
    ]
  })

    depends_on = [aws_s3_bucket_public_access_block.std17_s3_bucket-access]
}

resource "aws_s3_object" "std17_index_html" {
    bucket = aws_s3_bucket.std17_s3_bucket.id
    key    = "index.html"
    source = local.index_html_path
    etag   = filemd5(local.index_html_path)

    content_type = "text/html"
}

# ================================================================
# 2번 S3
resource "aws_s3_bucket" "std17_s3_bucket2" {
    bucket = var.bucket_name2
    tags   = { Name = var.bucket_name2 }
}

# 퍼블릭 액세스 관리
resource "aws_s3_bucket_public_access_block" "std17_s3_bucket2-access" {
    bucket                  = aws_s3_bucket.std17_s3_bucket2.id
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
}

# 버킷에 외부 접근에 대한 정책 정의
resource "aws_s3_bucket_policy" "std17_s3_bucket2_policy" {
    bucket = aws_s3_bucket.std17_s3_bucket2.id

    policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.std17_s3_bucket2.arn}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": aws_cloudfront_distribution.std17_cdn.arn
                }
            }
        }
    ]
  })

    depends_on = [aws_s3_bucket_public_access_block.std17_s3_bucket2-access]
}

resource "aws_s3_object" "std17_about_html" {
    bucket = aws_s3_bucket.std17_s3_bucket2.id
    key    = "about.html"
    source = local.about_html_path
    etag   = filemd5(local.about_html_path)

    content_type = "text/html"
}
# ================================================================
# 3번 S3
resource "aws_s3_bucket" "std17_s3_bucket3" {
    bucket = var.bucket_name3
    tags   = { Name = var.bucket_name3 }
}

# 퍼블릭 액세스 관리
resource "aws_s3_bucket_public_access_block" "std17_s3_bucket3-access" {
    bucket                  = aws_s3_bucket.std17_s3_bucket3.id
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
}

# 버킷에 외부 접근에 대한 정책 정의
resource "aws_s3_bucket_policy" "std17_s3_bucket3_policy" {
    bucket = aws_s3_bucket.std17_s3_bucket3.id

    policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.std17_s3_bucket3.arn}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": aws_cloudfront_distribution.std17_cdn.arn
                }
            }
        }
    ]
  })

    depends_on = [aws_s3_bucket_public_access_block.std17_s3_bucket3-access]
}

resource "aws_s3_object" "std17_services_html" {
    bucket = aws_s3_bucket.std17_s3_bucket3.id
    key    = "services.html"
    source = local.services_html_path
    etag   = filemd5(local.services_html_path)

    content_type = "text/html"
}
