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

# variable "api_invoke_url" {
#   description = "API Gateway invoke URL"
#   type        = string
# }

# variable "api_stage_name" {
#   description = "API Gateway stage name"
#   type        = string
# }