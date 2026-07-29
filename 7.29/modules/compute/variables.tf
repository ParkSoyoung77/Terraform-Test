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
    default     = "t3.nano"
}

variable "instance_ami" {
    description = "EC2 인스턴스 소스 AMI (Ubuntu)"
    type        = string
    default     = "ami-0086ee55a149bd32e"
}
