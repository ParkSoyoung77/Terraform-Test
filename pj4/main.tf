# ==================================================================
# 1: iam (다른 모듈에 앞서 역할부터 생성)
# ==================================================================
module "iam" {
    source = "./modules/iam"
}

# ==================================================================
# 2: network
# ==================================================================
module "network" {
    source      = "./modules/network"
    azs          = var.azs
    vpc1_cidr    = "10.0.0.0/24"
    aws_region    = var.aws_region
}

module "network2" {
    source      = "./modules/network2"
    azs          = var.azs
    vpc2_cidr    = "10.0.10.0/24"
    aws_region    = var.aws_region
}

# ==================================================================
# 3: security
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
# 4: VPC Peering
# ==================================================================
module "peering" {
    source = "./modules/peering"

    requester_vpc_id    = module.network.vpc_id
    accepter_vpc_id      = module.network2.vpc_id
    vpc1_cidr             = module.network.vpc_cidr
    vpc2_cidr             = module.network2.vpc_cidr
    vpc1_public_rt_id    = module.network.public_rt_id
    vpc1_private_rt_id   = module.network.private_rt_id
    vpc2_private_rt_id   = module.network2.private_rt_id

    depends_on = [module.network, module.network2]
}

# ==================================================================
# 5: ACM (www/api SAN 인증서)
# ==================================================================
module "acm" {
    source = "./modules/acm"

    root_domain      = var.root_domain
    san_list          = [var.domain_name, var.api_domain_name]
    hosted_zone_id    = data.aws_route53_zone.std17_zone.zone_id
}

# ==================================================================
# 6: database (network2)
# ==================================================================
module "database" {
    source = "./modules/database"

    db_private_subnet_ids = module.network2.private_subnet_ids
    security_group_id     = module.security2.db_sg_id
    db_name                = var.db_name
    multi_az                = true

    rds_proxy_role_arn   = module.iam.rds_proxy_role_arn
    rds_proxy_role_name  = module.iam.rds_proxy_role_name

    depends_on = [module.network2, module.security2, module.peering, module.iam]
}

# ==================================================================
# 7: storage: S3 정적 웹사이트 (4개 버킷)
# ==================================================================
module "storage" {
    source = "./modules/storage"

    bucket_name  = "std17-ex-bucket"
    bucket_name1 = "std17-ubuntu-bucket1"
    bucket_name2 = "std17-mysql-bucket2"
    bucket_name3 = "std17-docker-bucket3"
}

# ==================================================================
# 8: api (Lambda + REST API, api.sy99.cloud 전용)
# ==================================================================
module "api" {
    source = "./modules/api"

    private_subnet_ids = module.network.private_subnet_ids
    security_group_id  = module.security.test_sg_id

    db_secret_arn      = module.database.master_user_secret_arn
    db_proxy_endpoint  = module.database.rds_proxy_endpoint   # RDS 직결 아님, Proxy 경유
    db_name             = var.db_name

    lambda_role_arn   = module.iam.lambda_role_arn
    lambda_role_name  = module.iam.lambda_role_name

    api_domain_name       = var.api_domain_name
    acm_certificate_arn   = module.acm.certificate_arn
    hosted_zone_id         = data.aws_route53_zone.std17_zone.zone_id

    depends_on = [module.network, module.security, module.database, module.peering, module.iam, module.acm]
}

# ==================================================================
# 9: alb (HTTP 백엔드, www.sy99.cloud는 web_gateway가 담당)
# ==================================================================
module "alb" {
    source = "./modules/alb"

    vpc_id            = module.network.vpc_id
    public_subnet_ids = module.network.public_subnet_ids
    security_group_id = module.security.test_sg_id
}

# ==================================================================
# 10: web_gateway (www.sy99.cloud - ALB/S3 프록시)
# ==================================================================
module "web_gateway" {
    source = "./modules/web_gateway"

    alb_dns_name = module.alb.alb_dns_name

    ubuntu_website_endpoint = module.storage.bucket1_website_endpoint
    mysql_website_endpoint  = module.storage.bucket2_website_endpoint
    docker_website_endpoint = module.storage.bucket3_website_endpoint

    web_domain_name       = var.domain_name
    acm_certificate_arn   = module.acm.certificate_arn
    hosted_zone_id         = data.aws_route53_zone.std17_zone.zone_id

    depends_on = [module.alb, module.storage, module.acm]
}

# ==================================================================
# 11: compute: nginx ASG
# ==================================================================
module "compute" {
    source = "./modules/compute"

    private_subnet_ids = module.network.private_subnet_ids
    security_group_id  = module.security.test_sg_id
    key_name            = var.key_name
    iam_instance_profile = module.iam.instance_profile_name

    target_group_arn = module.alb.target_group_arn

    depends_on = [module.network, module.security, module.storage, module.alb, module.iam]
}