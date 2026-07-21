variable "vpc1_id" {
    type        = string
    description = "network 모듈의 VPC id"
}

variable "vpc1_subnet_ids" {
    type        = list(string)
    description = "TGW attachment에 사용할 network VPC의 서브넷 id"
}

variable "vpc1_route_table_id" {
    type        = string
    description = "network VPC의 private route table id"
}

variable "vpc1_public_route_table_id" {
    type        = string
    description = "network VPC의 public route table id"
}

variable "vpc1_default_route_table_id" {
    type        = string
    description = "network VPC의 default(main) route table id"
}

variable "vpc1_cidr" {
    type        = string
    description = "network VPC의 CIDR"
}

variable "vpc2_id" {
    type        = string
    description = "network2 모듈의 VPC id"
}

variable "vpc2_subnet_ids" {
    type        = list(string)
    description = "TGW attachment에 사용할 network2 VPC의 서브넷 id"
}

variable "vpc2_route_table_id" {
    type        = string
    description = "network2 VPC의 private route table id"
}

variable "vpc2_public_route_table_id" {
    type        = string
    description = "network2 VPC의 public route table id"
}

variable "vpc2_default_route_table_id" {
    type        = string
    description = "network2 VPC의 default(main) route table id"
}

variable "vpc2_cidr" {
    type        = string
    description = "network2 VPC의 CIDR"
}

variable "vpc3_id" {
    type        = string
    description = "network3 모듈의 VPC id"
}

variable "vpc3_subnet_ids" {
    type        = list(string)
    description = "TGW attachment에 사용할 network3 VPC의 서브넷 id"
}

variable "vpc3_route_table_id" {
    type        = string
    description = "network3 VPC의 private route table id"
}

variable "vpc3_public_route_table_id" {
    type        = string
    description = "network3 VPC의 public route table id"
}

variable "vpc3_default_route_table_id" {
    type        = string
    description = "network3 VPC의 default(main) route table id"
}

variable "vpc3_cidr" {
    type        = string
    description = "network3 VPC의 CIDR"
}