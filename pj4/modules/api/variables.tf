# variable "private_subnet_ids" {
#   description = "Lambda가 위치할 프라이빗 서브넷 ID 리스트 (VPC1)"
#   type        = list(string)
# }

# variable "security_group_id" {
#   description = "Lambda에 적용할 보안그룹 ID"
#   type        = string
# }

# variable "db_secret_arn" {
#   description = "RDS 마스터 계정 Secrets Manager ARN"
#   type        = string
# }

# variable "db_proxy_endpoint" {
#   description = "RDS Proxy 엔드포인트 (Lambda가 여기로 접속)"
#   type        = string
# }

# variable "db_name" {
#   description = "Lambda가 연결 테스트에 사용할 데이터베이스 이름"
#   type        = string
#   default     = "studydb"
# }

# variable "lambda_role_arn" {
#   description = "iam 모듈에서 생성한 Lambda 역할 ARN"
#   type        = string
# }

# variable "lambda_role_name" {
#   description = "iam 모듈에서 생성한 Lambda 역할 이름 (시크릿 정책 부착용)"
#   type        = string
# }

# variable "api_domain_name" {
#   description = "Lambda 전용 API Gateway 사용자 지정 도메인 (api.sy99.cloud)"
#   type        = string
# }

# variable "acm_certificate_arn" {
#   description = "REGIONAL ACM 인증서 ARN"
#   type        = string
# }

# variable "hosted_zone_id" {
#   description = "Route53 호스팅 영역 ID"
#   type        = string
# }