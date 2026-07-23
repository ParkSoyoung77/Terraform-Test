variable "bucket_name" {
    description = "S3 버킷 이름"
    type        = string
    default     = "std17-ex-bucket"
}

variable "bucket_name1" {
    description = "S3 버킷 이름"
    type        = string
    default     = "std17-ubuntu-bucket1"
}

variable "bucket_name2" {
    description = "S3 버킷 이름"
    type        = string
    default     = "std17-mysql-bucket2"
}

variable "bucket_name3" {
    description = "S3 버킷 이름"
    type        = string
    default     = "std17-docker-bucket3"
}

# ================================================================

variable "index_html_path" {
    description = "업로드할 index.html 경로"
    type        = string
    default     = ""
}

variable "ubuntu_html_path" {
    description = "업로드할 ubuntu.html 경로"
    type    = string
    default = ""
}

variable "mysql_html_path" {
    description = "업로드할 mysql.html 경로"
    type    = string
    default = ""
}

variable "docker_html_path" {
    description = "업로드할 docker.html 경로"
    type    = string
    default = ""
}