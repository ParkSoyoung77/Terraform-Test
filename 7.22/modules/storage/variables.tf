variable "bucket_name" {
    description = "S3 버킷 이름"
    type        = string
    default     = "std17-ex-bucket"
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