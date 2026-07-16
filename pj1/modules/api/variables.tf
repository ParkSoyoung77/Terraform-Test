variable "s3_website_endpoint" {
  description = "S3 정적 웹사이트 엔드포인트 URL"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lambda가 위치할 프라이빗 서브넷 ID 리스트 (RDS와 통신 + NAT로 Secrets Manager 접근)"
  type        = list(string)
}

variable "security_group_id" {
  description = "Lambda에 적용할 보안그룹 ID (RDS 접속 허용된 SG)"
  type        = string
}

variable "db_secret_arn" {
  description = "RDS 마스터 계정 정보를 담은 Secrets Manager ARN"
  type        = string
}

variable "db_host" {
  description = "RDS MySQL 엔드포인트 주소 (포트 제외)"
  type        = string
}

variable "db_name" {
  description = "Lambda가 연결 테스트에 사용할 데이터베이스 이름"
  type        = string
  default     = "studydb"
}