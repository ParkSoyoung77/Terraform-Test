variable "vpc_id" {
    description = "보안그룹을 생성할 VPC ID (두 번째 VPC)"
    type        = string
}

variable "allowed_cidr_blocks" {
    description = "RDS 3306 접근을 허용할 CIDR (VPC1 CIDR, TGW 경유)"
    type        = list(string)
}