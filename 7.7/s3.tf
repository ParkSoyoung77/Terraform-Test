resource "aws_s3_bucket" "std17_s3_bucket" {
    bucket = "std17-s3-bucket"
    tags = { Name = "std17-s3-bucket"}
}

# 버전 관리: 삭제 시, 복구 가능
resource "aws_s3_bucket_versioning" "std17_s3_bucket_versioning" {
    bucket = aws_s3_bucket.std17_s3_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

# 퍼블릭 액세스 관리
resource "aws_s3_bucket_public_access_block" "std17_s3_bucket-access" {
    bucket = aws_s3_bucket.std17_s3_bucket.id
    block_public_acls = false
    ignore_public_acls = false
    block_public_policy = false
    restrict_public_buckets = false
}

# 정적 웹사이트 호스팅 기능 활성화
resource "aws_s3_bucket_website_configuration" "std17_s3_bucket_web_config"{
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
        "Version": "2012-10-17"
        "Statement": [
            {
                Sid = "Statement1"
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = "${aws_s3_bucket.std17_s3_bucket.arn}/*"
            }
        ]
    })

    depends_on = [aws_s3_bucket_public_access_block.std17_s3_bucket-access]
}



# ================================================================

# index.html 업로드
resource "aws_s3_object" "std17_index_html"{
    bucket = aws_s3_bucket.std17_s3_bucket.id
    key = "index.html"
    source = "/mnt/c/Users/user/Downloads/alb/ec2nginx80/index.html"
    etag = filemd5("/mnt/c/Users/user/Downloads/alb/ec2nginx80/index.html")

    content_type = "text/html"
}

# 폴더 생성
resource "aws_s3_object" "std17_folder" {
    bucket = aws_s3_bucket.std17_s3_bucket.id
    key = "실습예제/"
}

# 실습예제 폴더에 업로드
resource "aws_s3_object" "std17_default_css" {
  bucket = aws_s3_bucket.std17_s3_bucket.id
  key    = "실습예제/default.css"
  source = "/mnt/c/Users/user/Downloads/default.css"
  etag   = filemd5("/mnt/c/Users/user/Downloads/default.css")

  content_type = "text/css"
}

