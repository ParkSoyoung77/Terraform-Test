output "availability_zone" {
    value       = data.aws_availability_zones.az.names
}

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

output "test_sg_id" {
    value = module.security.test_sg_id
}

output "cloudfront_domain_name" {
    value = aws_cloudfront_distribution.std17_cdn.domain_name
}
