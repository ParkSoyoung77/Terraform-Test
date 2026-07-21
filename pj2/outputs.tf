output "availability_zone" {
    value       = data.aws_availability_zones.az.names
    description = "사용 가능한 가용영역 정보"
}

# ---------------- network (VPC1) ----------------
output "vpc_id"             { value = module.network.vpc_id }
output "public_subnets_id"  { value = module.network.public_subnet_ids }
output "private_subnets_id" { value = module.network.private_subnet_ids }
output "igw_id"              { value = module.network.igw_id }
output "nat_id"               { value = module.network.nat_id }

# ---------------- network2 (VPC2) ----------------
output "vpc2_id"             { value = module.network2.vpc_id }
output "public_subnets2_id"  { value = module.network2.public_subnet_ids }
output "private_subnets2_id" { value = module.network2.private_subnet_ids }
output "igw2_id"              { value = module.network2.igw_id }
output "nat2_id"               { value = module.network2.nat_id }

# ---------------- security ----------------
output "test_sg_id" { value = module.security.test_sg_id }
output "db_sg_id"     { value = module.security2.db_sg_id }

# ---------------- compute ----------------
output "alb_dns_name" { value = module.compute.alb_dns_name }

# ---------------- database ----------------
output "db_endpoint"           { value = module.database.db_endpoint }
output "db_master_secret_arn" { value = module.database.master_user_secret_arn }

# ---------------- storage ----------------
output "s3_website_endpoint" { value = module.storage.website_endpoint }

# ---------------- api ----------------
output "api_endpoint" { value = module.api.api_endpoint }

# ---------------- 진입점 ----------------
output "site_url" { value = "https://${var.domain_name}" }