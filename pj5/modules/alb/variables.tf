variable "vpc_id" {
    type = string
}

variable "public_subnet_ids" {
    type = list(string)
}

variable "alb_sg_id" {
    type = string
}

variable "domain_name" {
    description = "ACM 인증서 발급 + Route53 DNS 검증에 쓰일 도메인"
    type        = string
}