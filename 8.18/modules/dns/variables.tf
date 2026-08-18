variable "zone_name" {
  description = "프라이빗 호스팅 영역 도메인 이름"
  type        = string
  default     = "std17.internal"
}

variable "vpc_id" {
  description = "호스팅 영역을 연결할 VPC ID"
  type        = string
}

variable "nlb_dns_name" {
  description = "Alias 레코드로 연결할 NLB DNS 이름"
  type        = string
}

variable "nlb_zone_id" {
  description = "Alias 레코드로 연결할 NLB의 zone_id"
  type        = string
}

variable "ec2_private_ip" {
  description = "EC2 A 레코드로 등록할 프라이빗 IP"
  type        = string
}