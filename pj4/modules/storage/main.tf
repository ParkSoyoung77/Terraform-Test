# html 업로드
locals {
    index_html_path    = var.index_html_path != "" ? var.index_html_path : "${path.module}/files/index.html"
    ubuntu_html_path  = var.ubuntu_html_path != "" ? var.ubuntu_html_path : "${path.module}/files/ubuntu.html"
    mysql_html_path  = var.mysql_html_path != "" ? var.mysql_html_path : "${path.module}/files/mysql.html"
    docker_html_path  = var.docker_html_path != "" ? var.docker_html_path : "${path.module}/files/docker.html"
}
# ================================================================
# userdata용 S3
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

resource "aws_s3_object" "std17_index_html" {
    bucket = aws_s3_bucket.std17_s3_bucket.id
    key    = "index.html"
    source = local.index_html_path
    etag   = filemd5(local.index_html_path)

    content_type = "text/html"
}
# ================================================================

# 1번 S3
resource "aws_s3_bucket" "std17_s3_bucket1" {
    bucket = var.bucket_name1
    tags   = { Name = var.bucket_name }
}

# 퍼블릭 액세스 관리
resource "aws_s3_bucket_public_access_block" "std17_s3_bucket1-access" {
    bucket                  = aws_s3_bucket.std17_s3_bucket1.id
    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = false
    restrict_public_buckets = false
}

resource "aws_s3_object" "std17_ubuntu_html" {
    bucket = aws_s3_bucket.std17_s3_bucket1.id
    key    = "ubuntu.html"
    source = local.ubuntu_html_path
    etag   = filemd5(local.ubuntu_html_path)

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
    block_public_policy     = false
    restrict_public_buckets = false
}

resource "aws_s3_object" "std17_mysql_html" {
    bucket = aws_s3_bucket.std17_s3_bucket2.id
    key    = "mysql.html"
    source = local.mysql_html_path
    etag   = filemd5(local.mysql_html_path)

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
    block_public_policy     = false
    restrict_public_buckets = false
}

resource "aws_s3_object" "std17_docker_html" {
    bucket = aws_s3_bucket.std17_s3_bucket3.id
    key    = "docker.html"
    source = local.docker_html_path
    etag   = filemd5(local.docker_html_path)

    content_type = "text/html"
}

# ==================================================================
# 정적 웹사이트 호스팅 (ubuntu/mysql/docker 3개 버킷만 - API Gateway가 공인 경로로 호출)
# ==================================================================
resource "aws_s3_bucket_website_configuration" "std17_bucket1_website" {
    bucket = aws_s3_bucket.std17_s3_bucket1.id
    index_document { suffix = "ubuntu.html" }
}

resource "aws_s3_bucket_website_configuration" "std17_bucket2_website" {
    bucket = aws_s3_bucket.std17_s3_bucket2.id
    index_document { suffix = "mysql.html" }
}

resource "aws_s3_bucket_website_configuration" "std17_bucket3_website" {
    bucket = aws_s3_bucket.std17_s3_bucket3.id
    index_document { suffix = "docker.html" }
}

resource "aws_s3_bucket_policy" "std17_bucket1_policy" {
    bucket     = aws_s3_bucket.std17_s3_bucket1.id
    depends_on = [aws_s3_bucket_public_access_block.std17_s3_bucket1-access]

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Sid       = "PublicReadGetObject"
            Effect    = "Allow"
            Principal = "*"
            Action    = "s3:GetObject"
            Resource  = "${aws_s3_bucket.std17_s3_bucket1.arn}/*"
        }]
    })
}

resource "aws_s3_bucket_policy" "std17_bucket2_policy" {
    bucket     = aws_s3_bucket.std17_s3_bucket2.id
    depends_on = [aws_s3_bucket_public_access_block.std17_s3_bucket2-access]

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Sid       = "PublicReadGetObject"
            Effect    = "Allow"
            Principal = "*"
            Action    = "s3:GetObject"
            Resource  = "${aws_s3_bucket.std17_s3_bucket2.arn}/*"
        }]
    })
}

resource "aws_s3_bucket_policy" "std17_bucket3_policy" {
    bucket     = aws_s3_bucket.std17_s3_bucket3.id
    depends_on = [aws_s3_bucket_public_access_block.std17_s3_bucket3-access]

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Sid       = "PublicReadGetObject"
            Effect    = "Allow"
            Principal = "*"
            Action    = "s3:GetObject"
            Resource  = "${aws_s3_bucket.std17_s3_bucket3.arn}/*"
        }]
    })
}