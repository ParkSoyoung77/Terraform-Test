variable "private_subnet_ids" {
    description = "DB Subnet Group에 사용할 프라이빗 서브넷 ID 리스트"
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

variable "db_username" {
    description = "DB 관리자 계정명"
    type        = string
    default     = "admin"
}

variable "db_password" {
    description = "DB 관리자 비밀번호"
    type        = string
    sensitive   = true
}
