variable "vpc_id" {
    description = "ALB/타겟그룹이 속할 VPC ID"
    type        = string
}

variable "public_subnet_ids" {
    description = "퍼블릭 서브넷 ID 리스트 (EC2, ALB용)"
    type        = list(string)
}

# variable "private_subnet_ids" {
#     description = "프라이빗 서브넷 ID 리스트 (ASG, private EC2용)"
#     type        = list(string)
# }

variable "security_group_id" {
    description = "EC2/ALB/ASG에 적용할 보안그룹 ID"
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
    default     = "t3.micro"
}

variable "instance_ami" {
    description = "EC2 인스턴스 소스 AMI (Ubuntu)"
    type        = string
    default     = "ami-0fb110df4c5094d21"
}

variable "amazon_ami" {
    description = "EC2 인스턴스 소스 AMI (Amazon Linux)"
    type        = string
    default     = "ami-0258f6159529e6b5b"
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to EC2"
  type        = string
  default     = ""
}

variable "route_table_ids" {
  description = "Route table IDs to associate with the S3 gateway endpoint"
  type        = list(string)
}