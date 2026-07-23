output "availability_zone" {
  description = "사용 가능한 가용영역 정보"
  value       = data.aws_availability_zones.az.names
}

# ---------------- network (VPC1) ----------------
output "vpc_id" {
  description = "VPC1 ID"
  value       = module.network.vpc_id
}

output "public_subnets_id" {
  description = "VPC1 퍼블릭 서브넷 ID 리스트"
  value       = module.network.public_subnet_ids
}

output "private_subnets_id" {
  description = "VPC1 프라이빗 서브넷 ID 리스트"
  value       = module.network.private_subnet_ids
}

output "igw_id" {
  description = "VPC1 인터넷 게이트웨이 ID"
  value       = module.network.igw_id
}

output "nat_id" {
  description = "VPC1 NAT 게이트웨이 ID"
  value       = module.network.nat_id
}

# ---------------- network2 (DB VPC, 완전 격리형) ----------------
output "vpc2_id" {
  description = "DB VPC(VPC2) ID"
  value       = module.network2.vpc_id
}

output "private_subnets2_id" {
  description = "DB VPC 프라이빗 서브넷 ID 리스트"
  value       = module.network2.private_subnet_ids
}

# ---------------- security ----------------
output "test_sg_id" {
  description = "VPC1 공용 보안그룹 ID"
  value       = module.security.test_sg_id
}

output "db_sg_id" {
  description = "DB 보안그룹 ID"
  value       = module.security2.db_sg_id
}

# ---------------- peering ----------------
output "peering_connection_id" {
  description = "VPC1-VPC2 Peering Connection ID"
  value       = module.peering.peering_connection_id
}

# ---------------- database ----------------
# output "db_endpoint" {
#   description = "RDS Writer 엔드포인트"
#   value       = module.database.db_endpoint
# }

# output "db_proxy_endpoint" {
#   description = "RDS Proxy 엔드포인트 (Lambda 연결 대상)"
#   value       = module.database.rds_proxy_endpoint
# }

# output "db_master_secret_arn" {
#   description = "RDS 마스터 계정 Secrets Manager ARN"
#   value       = module.database.master_user_secret_arn
# }

# ---------------- storage ----------------
output "ubuntu_website_endpoint" {
  description = "ubuntu 버킷 정적 웹사이트 엔드포인트"
  value       = module.storage.bucket1_website_endpoint
}

output "mysql_website_endpoint" {
  description = "mysql 버킷 정적 웹사이트 엔드포인트"
  value       = module.storage.bucket2_website_endpoint
}

output "docker_website_endpoint" {
  description = "docker 버킷 정적 웹사이트 엔드포인트"
  value       = module.storage.bucket3_website_endpoint
}

# ---------------- alb ----------------
output "alb_dns_name" {
  description = "ALB DNS 이름 (web_gateway의 HTTP_PROXY 대상)"
  value       = module.alb.alb_dns_name
}

# ---------------- api ----------------
# output "api_endpoint" {
#   description = "api.sy99.cloud 최종 호출 URL"
#   value       = module.api.invoke_url
# }

# ---------------- 진입점 ----------------
output "site_url" {
  description = "www.sy99.cloud 최종 진입점 URL"
  value       = module.web_gateway.invoke_url
}