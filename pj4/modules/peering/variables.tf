variable "requester_vpc_id" {
  description = "Peering 요청자 VPC ID (VPC1, 웹)"
  type        = string
}

variable "accepter_vpc_id" {
  description = "Peering 수락자 VPC ID (VPC2, DB)"
  type        = string
}

variable "vpc1_cidr" {
  description = "VPC1(웹) CIDR 블록"
  type        = string
}

variable "vpc2_cidr" {
  description = "VPC2(DB) CIDR 블록"
  type        = string
}

variable "vpc1_public_rt_id" {
  description = "VPC1 퍼블릭 라우팅 테이블 ID"
  type        = string
}

variable "vpc1_private_rt_id" {
  description = "VPC1 프라이빗 라우팅 테이블 ID"
  type        = string
}

variable "vpc2_private_rt_id" {
  description = "VPC2 프라이빗 라우팅 테이블 ID"
  type        = string
}