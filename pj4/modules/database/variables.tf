variable "db_private_subnet_ids" {
  description = "DB Subnet Group에 사용할 프라이빗 서브넷 ID 리스트 (VPC2, 최소 2 AZ)"
  type        = list(string)
}

variable "security_group_id" {
  description = "RDS에 적용할 보안그룹 ID"
  type        = string
}

variable "engine_version" {
  description = "MySQL 엔진 버전"
  type        = string
  default     = "8.4.9"
}

variable "instance_class" {
  description = "RDS 인스턴스 클래스"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "초기 생성할 데이터베이스 이름"
  type        = string
  default     = "studydb"
}

variable "multi_az" {
  description = "Multi-AZ 배포 여부"
  type        = bool
  default     = false
}

variable "rds_proxy_role_arn" {
  description = "iam 모듈에서 생성한 RDS Proxy용 IAM Role ARN"
  type        = string
}

variable "rds_proxy_role_name" {
  description = "iam 모듈에서 생성한 RDS Proxy용 IAM Role 이름 (시크릿 정책 부착용)"
  type        = string
}