variable "private_subnet_ids" {
  description = "Lambda가 위치할 프라이빗 서브넷 ID 리스트 (VPC1)"
  type        = list(string)
}

variable "security_group_id" {
  description = "Lambda에 적용할 보안그룹 ID"
  type        = string
}

variable "db_secret_arn" {
  description = "RDS 마스터 계정 Secrets Manager ARN"
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