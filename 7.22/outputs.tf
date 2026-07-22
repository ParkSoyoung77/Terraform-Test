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
