# ==================================================================
# 1계층: network
# ==================================================================
module "network" {
    source = "./modules/network"
    azs    = var.azs
}

module "network2" {
    source = "./modules/network2"
    azs    = var.azs
}

# ==================================================================
# 2계층: security
# ==================================================================
module "security" {
    source = "./modules/security"
    vpc_id = module.network.vpc_id
}

module "security2" {
    source = "./modules/security2"

    vpc_id              = module.network2.vpc_id
    allowed_cidr_blocks = [module.network.vpc_cidr]
}

# ==================================================================
# VPC 연결: tgw
# ==================================================================
module "tgw" {
    source = "./modules/tgw"

    vpc1_id                     = module.network.vpc_id
    vpc1_subnet_ids             = module.network.private_subnet_ids
    vpc1_route_table_id         = module.network.private_rt_id
    vpc1_public_route_table_id  = module.network.public_rt_id
    vpc1_default_route_table_id = module.network.default_rt_id
    vpc1_cidr                   = module.network.vpc_cidr

    vpc2_id                     = module.network2.vpc_id
    vpc2_subnet_ids             = module.network2.private_subnet_ids
    vpc2_route_table_id         = module.network2.private_rt_id
    vpc2_public_route_table_id  = module.network2.public_rt_id
    vpc2_default_route_table_id = module.network2.default_rt_id
    vpc2_cidr                   = module.network2.vpc_cidr

    depends_on = [module.network, module.network2]
}

# ==================================================================
# database (VPC2)
# ==================================================================
module "database" {
    source = "./modules/database"

    db_private_subnet_ids = module.network2.private_subnet_ids
    security_group_id     = module.security2.db_sg_id
    db_name                = var.db_name

    depends_on = [module.network2, module.security2, module.tgw]
}

# ==================================================================
# storage: S3 정적 웹사이트
# ==================================================================
module "storage" {
    source = "./modules/storage"

    bucket_name = var.domain_name
}

# ==================================================================
# api: Lambda + API Gateway
# ==================================================================
module "api" {
    source = "./modules/api"

    private_subnet_ids = module.network.private_subnet_ids
    security_group_id  = module.security.test_sg_id
    db_secret_arn       = module.database.master_user_secret_arn
    db_host             = module.database.db_address
    db_name             = var.db_name

    depends_on = [module.network, module.security, module.database, module.tgw]
}

locals {
    api_gateway_domain = "${module.api.api_id}.execute-api.${var.aws_region}.amazonaws.com"
}

# ==================================================================
# compute: ALB (www.sy99.cloud 진입점, HTTP/HTTPS + redirect)
# ==================================================================
module "compute" {
    source = "./modules/compute"

    vpc_id            = module.network.vpc_id
    public_subnet_ids = module.network.public_subnet_ids
    security_group_id = module.security.test_sg_id

    acm_certificate_arn = data.aws_acm_certificate.std17_alb_cert.arn
    domain_name          = var.domain_name
    hosted_zone_id       = data.aws_route53_zone.std17_zone.zone_id
    aws_region            = var.aws_region

    s3_website_endpoint = module.storage.website_endpoint
    api_gateway_domain   = local.api_gateway_domain

    depends_on = [module.network, module.security, module.storage, module.api]
}

# ==================================================================
# compute2: nginx ASG (private, compute ALB 대상그룹에 등록)
# ==================================================================
module "compute2" {
    source = "./modules/compute2"

    private_subnet_ids = module.network.private_subnet_ids
    security_group_id  = module.security.test_sg_id
    key_name            = var.key_name
    target_group_arn   = module.compute.target_group_arn

    depends_on = [module.network, module.security, module.compute]
}