variable "bucket_name" {
    description = "S3 버킷 이름"
    type        = string
    default     = "std17-s3-bucket"
}

variable "index_html_path" {
    description = "업로드할 index.html 경로"
    type        = string
    default     = ""
}

variable "s3_bucket_regional_domain_name" {
  description = "CloudFront 원본으로 사용할 S3 버킷의 regional domain name"
  type        = string
}