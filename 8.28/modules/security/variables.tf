variable "vpc_id" {
  description = "보안그룹을 생성할 VPC ID"
  type        = string
}

variable "vpc_cidr" {
    description = "VPC CIDR 블록"
    type        = string
    default     = "10.0.0.0/16"
}