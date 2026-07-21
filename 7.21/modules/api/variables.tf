variable "hosted_zone_id" {
    description = "sy99.cloud 호스팅 영역 ID"
    type        = string
}

variable "custom_domain_name" {
    description = "API Gateway에 매핑할 커스텀 도메인"
    type        = string
    default     = "apigw.sy99.cloud"
}

variable "acm_domain_name" {
    description = "콘솔에서 발급받은 ACM 인증서 조회용 도메인명"
    type        = string
    default     = "sy99.cloud"
}

variable "stage_name" {
    description = "API Gateway 배포 스테이지 이름"
    type        = string
    default     = "prod"
}