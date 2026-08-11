variable "bucket_name" {
    description = "S3 버킷 이름"
    type        = string
    default     = "std17-ex-bucket"
}

variable "mysql_html_path" {
    description = "업로드할 mysql.html 경로"
    type        = string
    default     = ""
}