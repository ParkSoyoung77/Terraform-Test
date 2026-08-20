output "s3_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = aws_vpc_endpoint.std17_gw_endpoint.id
}

output "ecr_api_endpoint_id" {
  description = "ECR API Interface 엔드포인트 ID"
  value       = aws_vpc_endpoint.std17_ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  description = "ECR DKR Interface 엔드포인트 ID"
  value       = aws_vpc_endpoint.std17_ecr_dkr.id
}