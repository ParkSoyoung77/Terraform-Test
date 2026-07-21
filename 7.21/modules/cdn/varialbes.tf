variable "domain_name" {
    description = "CloudFront에 연결할 도메인 (apex)"
    type        = string
    default     = "sy99.cloud"
}

variable "s3_bucket_website_endpoint" {
    description = "오리진으로 쓸 S3 정적 웹사이트 엔드포인트"
    type        = string
}

variable "hosted_zone_id" {
    description = "sy99.cloud 호스팅 영역 ID"
    type        = string
}

variable "acm_certificate_arn" {
    description = "콘솔에서 발급한 us-east-1 ACM 인증서 ARN"
    type        = string
}

variable "price_class" {
    description = "CloudFront 가격 등급"
    type        = string
    default     = "PriceClass_200"
}