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

# ---------------- network2 ----------------
output "vpc2_id" {
    value = module.network2.vpc2_id
}

output "public_subnets_id2" {
    value = module.network2.public_subnet_ids
}

output "igw_id2" {
    value = module.network2.igw_id
}

# ---------------- security ----------------
output "test_sg_id" {
    value = module.security.test_sg_id
}

# ---------------- security2 ----------------
# output "test_sg2_id" {
#     value = module.security2.test_sg2_id
# }