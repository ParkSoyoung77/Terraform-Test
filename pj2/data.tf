data "aws_availability_zones" "az" {
    state = "available"
}

data "aws_route53_zone" "std17_zone" {
    name = var.root_domain
}

# ALB(us-west-1)에 직접 사용할 리전 ACM 인증서 (콘솔에서 미리 발급된 것)
data "aws_acm_certificate" "std17_alb_cert" {
    domain      = "sy99.cloud"
    statuses    = ["ISSUED"]
    most_recent = true
}