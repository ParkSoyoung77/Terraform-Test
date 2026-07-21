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