variable "vpc_id" {
    description = "S3 엔드포인트가 속할 VPC ID"
    type        = string
}

variable "private_subnet_ids" {
    description = "프라이빗 서브넷 ID 리스트 (ASG용)"
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
    default     = "t3.micro"
}

variable "instance_ami" {
    description = "EC2 인스턴스 소스 AMI (Ubuntu)"
    type        = string
    default     = "ami-0fb110df4c5094d21"
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

# target_group_arns(복수) 삭제 -> target_group_arn(단수)로 교체
variable "target_group_arn" {
    description = "alb 모듈에서 생성한 nginx 타겟그룹 ARN"
    type        = string
}