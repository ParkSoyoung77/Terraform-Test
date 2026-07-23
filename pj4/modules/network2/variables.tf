variable "vpc2_cidr" {
  description = "VPC2 CIDR 블록"
  type        = string
  default     = "10.0.10.0/24"
}

variable "azs" {
  description = "사용할 가용영역 리스트"
  type        = list(string)
  default     = ["us-west-1a", "us-west-1c"]
}

variable "aws_region" {
  description = "Secrets Manager 엔드포인트 서비스명 구성용"
  type        = string
  default     = "us-west-1"
}