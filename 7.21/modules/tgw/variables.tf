variable "vpc1_id" {
    type        = string
    description = "network 모듈의 VPC id"
}

variable "vpc1_subnet_ids" {
    type        = list(string)
    description = "TGW attachment에 사용할 network VPC의 서브넷 id (보통 private subnet 1개씩, AZ별로)"
}

variable "vpc2_id" {
    type        = string
    description = "network2 모듈의 VPC id"
}

variable "vpc2_subnet_ids" {
    type        = list(string)
    description = "TGW attachment에 사용할 network2 VPC의 서브넷 id"
}