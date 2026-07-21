variable "vpc_cidr" {
    description = "VPC2 CIDR 블록"
    type        = string
    default     = "10.10.0.0/16"
}

variable "azs" {
    description = "사용할 가용영역 리스트 (public/private subnet count.index 순서와 매칭)"
    type        = list(string)
    default     = ["us-west-1a", "us-west-1c"]
}
