# ==================================================================
# std17-ex-bucket
# ==================================================================
resource "aws_s3_bucket" "std17_s3_bucket" {
    bucket = var.bucket_name
    tags   = { Name = var.bucket_name }
}

# 퍼블릭 액세스 관리
resource "aws_s3_bucket_public_access_block" "std17_s3_bucket-access" {
    bucket                  = aws_s3_bucket.std17_s3_bucket.id
    block_public_acls       = false
    ignore_public_acls      = false
    block_public_policy     = false
    restrict_public_buckets = false
}

# 정적 웹사이트 호스팅 기능 활성화
resource "aws_s3_bucket_website_configuration" "std17_s3_bucket_web_config" {
    bucket = aws_s3_bucket.std17_s3_bucket.id
    index_document {
        suffix = "index.html"
    }
    error_document {
        key = "error.html"
    }
}

# 버킷에 외부 접근에 대한 정책 정의
resource "aws_s3_bucket_policy" "std17_s3_bucket_policy" {
    bucket = aws_s3_bucket.std17_s3_bucket.id

    policy = jsonencode({
        "Version" : "2012-10-17"
        "Statement" : [
            {
                Sid       = "PublicReadGetObject"
                Effect    = "Allow"
                Principal = "*"
                Action    = "s3:GetObject"
                Resource  = "${aws_s3_bucket.std17_s3_bucket.arn}/*"
            }
        ]
    })

    depends_on = [aws_s3_bucket_public_access_block.std17_s3_bucket-access]
}

# ================================================================

# index.html 업로드
locals {
    index_html_path = var.index_html_path != "" ? var.index_html_path : "${path.module}/files/index.html"
}

resource "aws_s3_object" "std17_index_html" {
    bucket = aws_s3_bucket.std17_s3_bucket.id
    key    = "index.html"
    source = local.index_html_path
    etag   = filemd5(local.index_html_path)

    content_type = "text/html"
}

# ==================================================================
# www.sy99.cloud
# ==================================================================
resource "aws_s3_bucket" "std17_domain_s3_bucket" {
    bucket = var.domain_bucket_name
    tags   = { Name = var.domain_bucket_name }
}

# 퍼블릭 액세스 관리
resource "aws_s3_bucket_public_access_block" "std17_domain_s3_bucket-access" {
    bucket                  = aws_s3_bucket.std17_domain_s3_bucket.id
    block_public_acls       = false
    ignore_public_acls      = false
    block_public_policy     = false
    restrict_public_buckets = false
}

# 정적 웹사이트 호스팅 기능 활성화
resource "aws_s3_bucket_website_configuration" "std17_domain_s3_bucket_web_config" {
    bucket = aws_s3_bucket.std17_domain_s3_bucket.id
    index_document {
        suffix = "index.html"
    }
    error_document {
        key = "error.html"
    }
}

# 버킷에 외부 접근에 대한 정책 정의
resource "aws_s3_bucket_policy" "std17_domain_s3_bucket_policy" {
    bucket = aws_s3_bucket.std17_domain_s3_bucket.id

    policy = jsonencode({
        "Version" : "2012-10-17"
        "Statement" : [
            {
                Sid       = "PublicReadGetObject"
                Effect    = "Allow"
                Principal = "*"
                Action    = "s3:GetObject"
                Resource  = "${aws_s3_bucket.std17_domain_s3_bucket.arn}/*"
            }
        ]
    })

    depends_on = [aws_s3_bucket_public_access_block.std17_domain_s3_bucket-access]
}

# ================================================================

# index.html 업로드
locals {
    html1_path = "${path.module}/files/html1.html"
    html2_path = "${path.module}/files/html2.html"
}

resource "aws_s3_object" "std17_html1" {
    bucket = aws_s3_bucket.std17_domain_s3_bucket.id
    key    = "html1.html"
    source = local.html1_path
    etag   = filemd5(local.html1_path)

    content_type = "text/html"
}

resource "aws_s3_object" "std17_html2" {
    bucket = aws_s3_bucket.std17_domain_s3_bucket.id
    key    = "html2.html"
    source = local.html2_path
    etag   = filemd5(local.html2_path)

    content_type = "text/html"
}