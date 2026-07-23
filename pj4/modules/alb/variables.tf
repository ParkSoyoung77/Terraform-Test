variable "vpc_id" {
  description = "ALB/타겟그룹이 속할 VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 리스트 (ALB용)"
  type        = list(string)
}

variable "security_group_id" {
  description = "ALB에 적용할 보안그룹 ID"
  type        = string
}