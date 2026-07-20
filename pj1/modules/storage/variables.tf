variable "bucket_name" {
    description = "S3 버킷 이름"
    type        = string
    default     = "std17-s3-bucket"
}

variable "bucket_name2" {
    description = "S3 버킷 이름"
    type        = string
    default     = "std17-s3-bucket2"
}

variable "bucket_name3" {
    description = "S3 버킷 이름"
    type        = string
    default     = "std17-s3-bucket3"
}

variable "index_html_path" {
    description = "업로드할 index.html 경로"
    type        = string
    default     = ""
}

variable "about_html_path" {
    description = "업로드할 about.html 경로"
    type    = string
    default = ""
}

variable "services_html_path" {
    description = "업로드할 services.html 경로"
    type    = string
    default = ""
}

# modules/storage/variables.tf 에 추가
variable "oac_id" {
  description = "CloudFront Origin Access Control ID (root에서 전달받음)"
  type        = string
}