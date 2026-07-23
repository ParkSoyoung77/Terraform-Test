variable "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 리스트 (ASG용)"
  type        = list(string)
}

variable "security_group_id" {
  description = "EC2/ASG에 적용할 보안그룹 ID"
  type        = string
}

variable "target_group_arn" {
  description = "compute 모듈 ALB의 대상그룹 ARN"
  type        = string
}

variable "key_name" {
  description = "EC2 키페어 이름"
  type        = string
  default     = "std17-key"
}

variable "instance_ami" {
  description = "EC2 인스턴스 소스 AMI (Ubuntu)"
  type        = string
  default     = "ami-0fb110df4c5094d21"
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to EC2"
  type        = string
  default     = ""
}
