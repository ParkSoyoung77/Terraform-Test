output "vpc_id" {
  description = "DB VPC(VPC2) ID"
  value       = aws_vpc.std17_db_vpc.id
}

output "vpc_cidr" {
  description = "DB VPC(VPC2) CIDR 블록"
  value       = aws_vpc.std17_db_vpc.cidr_block
}

output "default_rt_id" {
  description = "DB VPC 기본 라우팅 테이블 ID"
  value       = aws_default_route_table.std17_db_vpc_default_rt.id
}

output "private_subnet_ids" {
  description = "DB VPC 프라이빗 서브넷 ID 리스트"
  value       = aws_subnet.std17_private_subnets2[*].id
}

output "private_rt_id" {
  description = "DB VPC 프라이빗 라우팅 테이블 ID"
  value       = aws_route_table.std17_vpc_private_rt2.id
}

output "secretsmanager_endpoint_id" {
  description = "Secrets Manager Interface VPC Endpoint ID (완전 격리형 VPC 내부 통신용)"
  value       = aws_vpc_endpoint.std17_secretsmanager.id
}