# variable "hosted_zone_id" {
#     description = "sy99.cloud 호스팅 영역 ID"
#     type        = string
# }

# variable "custom_domain_name" {
#     description = "API Gateway에 매핑할 커스텀 도메인"
#     type        = string
#     default     = "apigw.sy99.cloud"
# }

# variable "acm_domain_name" {
#     description = "ACM 인증서 조회용 도메인명 (와일드카드 SAN 기준)"
#     type        = string
#     default     = "*.sy99.cloud"
# }

# variable "stage_name" {
#     description = "API Gateway 배포 스테이지 이름"
#     type        = string
#     default     = "prod"
# }

# variable "acm_certificate_arn" {
#     description = "콘솔에서 수동 발급한 와일드카드 ACM 인증서 ARN"
#     type        = string
#     default     = "arn:aws:acm:us-west-1:925047940866:certificate/3ca3481d-db28-4611-a3ad-6e6b45f9b29d"
# }