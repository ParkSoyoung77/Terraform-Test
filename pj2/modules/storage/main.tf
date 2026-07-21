resource "aws_s3_bucket" "std17_s3_bucket" {
    bucket = var.bucket_name
    tags   = { Name = var.bucket_name }
}

# CloudFront(OAC)만 접근하므로 퍼블릭 접근은 전면 차단
resource "aws_s3_bucket_public_access_block" "std17_s3_bucket-access" {
    bucket                  = aws_s3_bucket.std17_s3_bucket.id
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = true
    restrict_public_buckets = true
}

# 요구사항 4: "S3를 Static Website로 생성" 충족용 설정 (실제 서빙은 CloudFront가 담당)
resource "aws_s3_bucket_website_configuration" "std17_s3_bucket_web_config" {
    bucket = aws_s3_bucket.std17_s3_bucket.id
    index_document {
        suffix = "index.html"
    }
    error_document {
        key = "error.html"
    }
}

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