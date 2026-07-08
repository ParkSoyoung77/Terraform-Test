resource "aws_s3_bucket" "std17_s3_2_bucket" {
    bucket = "std17-s3-2-bucket"
    tags = { Name = "std17-s3-2-bucket"}
}

# index.html 업로드
resource "aws_s3_object" "std17_index_html_2"{
    bucket = aws_s3_bucket.std17_s3_2_bucket.id
    key = "index.html"
    source = "/mnt/c/Users/user/Downloads/alb/ec2nginx8080/index.html"
    etag = filemd5("/mnt/c/Users/user/Downloads/alb/ec2nginx8080/index.html")

    content_type = "text/html"
}

# 퍼블릭 액세스 관리
resource "aws_s3_bucket_public_access_block" "std17_s3_2_bucket-access" {
    bucket = aws_s3_bucket.std17_s3_2_bucket.id
    block_public_acls = true
    ignore_public_acls = true
    block_public_policy = false
    restrict_public_buckets = true
}

# 버킷에 외부 접근에 대한 정책 정의
resource "aws_s3_bucket_policy" "std17_s3_2_bucket_policy" {
    bucket = aws_s3_bucket.std17_s3_2_bucket.id

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
            "Resource": "${aws_s3_bucket.std17_s3_2_bucket.arn}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": aws_cloudfront_distribution.std17_cdn.arn
                }
            }
        }
    ]
})

    depends_on = [aws_cloudfront_distribution.std17_cdn]
}