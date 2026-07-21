data "aws_availability_zones" "az" {
    state = "available"
}

data "aws_route53_zone" "std17_zone" {
    name = var.root_domain
}

# 콘솔에서 미리 발급한 CloudFront용 us-east-1 ACM 인증서 조회
data "aws_acm_certificate" "std17_cdn_cert" {
    provider    = aws.us_east_1
    domain      = var.domain_name
    statuses    = ["ISSUED"]
    most_recent = true
}