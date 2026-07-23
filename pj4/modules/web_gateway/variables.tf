variable "alb_dns_name" {
  description = "메인 페이지(/) 프록시 대상 ALB DNS 이름"
  type        = string
}

variable "ubuntu_website_endpoint" {
  description = "ubuntu 버킷 정적 웹사이트 호스팅 엔드포인트"
  type        = string
}

variable "mysql_website_endpoint" {
  description = "mysql 버킷 정적 웹사이트 호스팅 엔드포인트"
  type        = string
}

variable "docker_website_endpoint" {
  description = "docker 버킷 정적 웹사이트 호스팅 엔드포인트"
  type        = string
}

variable "web_domain_name" {
  description = "정적 페이지 전용 API Gateway 사용자 지정 도메인 (www.sy99.cloud)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "REGIONAL ACM 인증서 ARN"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 호스팅 영역 ID"
  type        = string
}