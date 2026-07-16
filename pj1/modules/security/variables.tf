variable "vpc_id" {
    description = "보안그룹을 생성할 VPC ID"
    type        = string
}

variable "db_username" {
  description = "RDS 관리자 계정명"
  type        = string
}