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

variable "network_html_path" {
    description = "업로드할 network.html 경로"
    type    = string
    default = ""
}

variable "compute_html_path" {
    description = "업로드할 compute.html 경로"
    type    = string
    default = ""
}

variable "database_html_path" {
    description = "업로드할 database.html 경로"
    type    = string
    default = ""
}