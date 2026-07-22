variable "api_name" {
    description = "HTTP API 이름"
    type        = string
    default     = "std17-report-api"
}

variable "domain_website_endpoint" {
    description = "html1/html2를 서빙하는 S3(www.sy99.cloud) 웹사이트 엔드포인트"
    type        = string
}