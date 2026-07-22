variable "vpc_id" {
    type = string
}

variable "public_subnet_ids" {
    type = list(string)
}

variable "security_group_id" {
    description = "ALB에 적용할 보안그룹 ID (80/443 인바운드)"
    type        = string
}

variable "domain_name" {
    type    = string
    default = "www.sy99.cloud"
}

variable "hosted_zone_id" {
    type = string
}

variable "acm_certificate_arn" {
    type = string
}

variable "domain_website_endpoint" {
    description = "html1.html / html2.html이 있는 S3 웹사이트 엔드포인트"
    type        = string
}