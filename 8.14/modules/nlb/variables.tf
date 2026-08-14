variable "vpc_id" {
  description = "NLB 및 대상그룹이 속할 VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "NLB에 연결할 서브넷 ID 리스트 (내부 NLB이므로 보통 프라이빗 서브넷 권장)"
  type        = list(string)
}

variable "security_group_id" {
  description = "NLB에 할당할 보안그룹 ID (test-sg)"
  type        = string
}

variable "instance_id" {
  description = "대상그룹에 연결할 EC2 인스턴스 ID"
  type        = string
}