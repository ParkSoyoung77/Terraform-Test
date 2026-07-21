variable "vpc_id" {
    description = "ALB/타겟그룹이 속할 VPC ID"
    type        = string
}

variable "public_subnet_ids" {
    description = "퍼블릭 서브넷 ID 리스트 (ALB용)"
    type        = list(string)
}

variable "security_group_id" {
    description = "ALB에 적용할 보안그룹 ID"
    type        = string
}

variable "acm_certificate_arn" {
    description = "ALB HTTPS 리스너용 ACM 인증서 ARN (ALB와 같은 리전)"
    type        = string
}

variable "domain_name" {
    description = "www.sy99.cloud"
    type        = string
}

variable "hosted_zone_id" {
    description = "Route53 호스팅 영역 ID"
    type        = string
}

variable "s3_website_endpoint" {
    description = "S3 정적 웹사이트 엔드포인트 (redirect 대상, 요구사항 4)"
    type        = string
}

variable "api_gateway_domain" {
    description = "API Gateway execute-api 도메인 (redirect 대상, 요구사항 6)"
    type        = string
}