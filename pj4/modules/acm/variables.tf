variable "root_domain" {
  description = "ACM 인증서의 기본(primary) 도메인"
  type        = string
}

variable "san_list" {
  description = "인증서에 함께 포함할 SAN(Subject Alternative Name) 도메인 리스트"
  type        = list(string)
}

variable "hosted_zone_id" {
  description = "DNS 검증 레코드를 생성할 Route53 호스팅 영역 ID"
  type        = string
}