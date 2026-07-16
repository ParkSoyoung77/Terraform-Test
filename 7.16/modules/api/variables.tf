variable "s3_website_endpoint" {
  description = "S3 정적 웹사이트 엔드포인트 URL"
  type        = string
}

variable "lambda_function_arn" {
  description = "연동할 Lambda 함수 ARN"
  type        = string
}