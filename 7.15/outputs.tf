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
    value = module.compute.nat_instance_id
}

# ---------------- security ----------------
output "test_sg_id" {
    value = module.security.test_sg_id
}

# ---------------- compute ----------------
# output "alb_dns_name" {
#     value = module.compute.alb_dns_name
# }

# output "asg_name" {
#     value = module.compute.asg_name
# }

# ---------------- database ----------------
output "db_endpoint" {
    value = module.database.db_endpoint
}

# ---------------- storage ----------------
output "s3_website_endpoint" {
    value = module.storage.website_endpoint
}
