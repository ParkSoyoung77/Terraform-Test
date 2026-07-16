output "availability_zone" {
    value       = data.aws_availability_zones.az.names
    description = "사용 가능한 가용영역 정보"
}

# ---------------- network ----------------
output "vpc_id" {
    value = module.network.vpc_id
}

output "public_subnets_id" {
    value = module.network.public_subnet_ids
}

output "private_subnets_id" {
    value = module.network.private_subnet_ids
}

output "igw_id" {
    value = module.network.igw_id
}

output "nat_id" {
    value = module.network.nat_id
}

# ---------------- security ----------------
output "test_sg_id" {
    value = module.security.test_sg_id
}

# ---------------- compute ----------------
output "alb_dns_name" {
    value = module.compute.alb_dns_name
}

output "asg_name" {
    value = module.compute.asg_name
}

# ---------------- database ----------------
output "db_endpoint" {
    value = module.database.db_endpoint
}

# ---------------- storage ----------------
output "cloudfront_domain_name" {
    value = module.storage.cloudfront_domain_name
}

# ------------------ api ------------------
output "lambda_db_check_endpoint" {
    description = "브라우저에서 Success/Failure를 확인할 수 있는 API Gateway 엔드포인트"
    value       = "${module.api.api_endpoint}/lambda"
}