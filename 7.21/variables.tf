variable "aws_region" {
    description = "리소스를 생성할 AWS 리전"
    type        = string
    default     = "us-west-1"
}

variable "azs" {
    description = "사용할 가용영역 리스트"
    type        = list(string)
    default     = ["us-west-1a", "us-west-1c"]
}

variable "key_name" {
    description = "EC2 키페어 이름"
    type        = string
    default     = "std17-key"
}
