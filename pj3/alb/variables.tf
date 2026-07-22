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

variable "aws_region" {
    description = "S3 REST 엔드포인트용 리전"
    type        = string
    default     = "us-west-1"
}

variable "domain_bucket_name" {
    description = "html1.html / html2.html이 있는 S3 버킷 이름 (www.sy99.cloud)"
    type        = string
    default     = "www.sy99.cloud"
}