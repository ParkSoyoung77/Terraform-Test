output "vpc_id" {
    value = module.network.vpc_id
}

output "private_subnet_ids" {
    value = module.network.private_subnet_ids
}

output "ecs_cluster_name" {
    value = module.compute.cluster_name
}

output "db_instance_id" {
    value = module.compute.db_instance_id
}

output "alb_dns_name" {
    value = module.alb.alb_dns_name
}

output "site_url" {
    value = "https://${var.domain_name}"
}

output "mysql_credentials_secret_arn" {
    value = module.secrets.mysql_credentials_secret_arn
}