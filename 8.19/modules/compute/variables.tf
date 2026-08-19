variable "vpc_id" {
    description = "S3 엔드포인트가 속할 VPC ID"
    type        = string
}

variable "public_subnet_ids" {
    description = "프라이빗 서브넷 ID 리스트"
    type        = list(string)
}

variable "security_group_id" {
    description = "EC2에 적용할 보안그룹 ID"
    type        = string
}

variable "key_name" {
    description = "EC2 키페어 이름"
    type        = string
    default     = "std17-key"
}

variable "instance_type" {
    description = "EC2 인스턴스 타입"
    type        = string
    default     = "t3.small"
}

variable "instance_ami" {
    description = "EC2 인스턴스 소스 AMI (Ubuntu)"
    type        = string
    default     = "ami-0086ee55a149bd32e"
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to EC2"
  type        = string
  default     = ""
}

variable "route_table_ids" {
    description = "S3 게이트웨이 엔드포인트에 연결할 라우트테이블 ID"
    type        = list(string)
}

variable "fixed_private_ips" {
  description = "각 EC2에 배정할 고정 프라이빗 IP 리스트 (3개)"
  type        = list(string)
  default     = ["10.0.1.10", "10.0.2.10", "10.0.3.10"]
}

variable "ecr_endpoint_sg_id" {
  description = "security 모듈에서 생성한 ECR 엔드포인트용 보안그룹 ID"
  type        = string
}