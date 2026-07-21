variable "bucket_name" {
    description = "S3 버킷 이름"
    type        = string
    default     = "www.sy99.cloud"
}

variable "index_html_path" {
    description = "업로드할 index.html 경로"
    type        = string
    default     = ""
}

variable "aws_region" {
    description = "S3 버킷 리전"
    type        = string
    default     = "us-west-1"
}

variable "domain_name" {
    description = "S3 버킷 이름이자 레코드 이름 (예: www.sy99.cloud)"
    type        = string
}

variable "hosted_zone_id" {
    description = "sy99.cloud 호스팅 영역 ID"
    type        = string
}

variable "s3_website_hosted_zone_id" {
    description = "S3 웹사이트 엔드포인트의 리전별 고정 Route53 zone id"
    type        = string
    default     = "Z2F56UZL2M1ACD"  # us-west-1
}