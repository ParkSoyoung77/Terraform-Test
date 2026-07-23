output "certificate_arn" {
  description = "www.sy99.cloud / api.sy99.cloud를 커버하는 검증 완료 ACM 인증서 ARN"
  value       = aws_acm_certificate_validation.std17_cert_validation.certificate_arn
}