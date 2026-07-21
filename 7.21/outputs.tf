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

# ---------------- network2 ----------------
output "vpc2_id" {
    value = module.network2.vpc_id
}

output "public_subnets2_id" {
    value = module.network2.public_subnet_ids
}

output "private_subnets2_id" {
    value = module.network2.private_subnet_ids
}

output "igw2_id" {
    value = module.network2.igw_id
}
output "nat2_id" {
    value = module.network2.nat_id
}

# ---------------- network3 ----------------
output "vpc3_id" {
    value = module.network3.vpc_id
}

output "public_subnets3_id" {
    value = module.network3.public_subnet_ids
}

output "private_subnets3_id" {
    value = module.network3.private_subnet_ids
}

output "igw3_id" {
    value = module.network3.igw_id
}
output "nat3_id" {
    value = module.network3.nat_id
}

# ---------------- security ----------------
output "test_sg_id" {
    value = module.security.test_sg_id
}