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

output "igw_id" {
    value = module.network.igw_id
}

# ---------------- security ----------------
output "test_sg_id" {
    value = module.security.test_sg_id
}

# ---------------- nlb ----------------
output "nlb_dns_name" {
    description = "내부 NLB DNS 이름 (RDS/SSH 접속용)"
    value       = module.nlb.nlb_dns_name
}