# ==================================================================
# 1계층: network
# ==================================================================
module "network" {
    source = "./network"

    azs = var.azs
}

# ==================================================================
# 2계층: security (network에 의존)
# ==================================================================
module "security" {
    source = "./security"

    vpc_id = module.network.vpc_id
}

# ==================================================================
# storage: S3 (독립적, 다른 모듈과 의존관계 없음)
# ==================================================================
module "storage" {
    source = "./storage"
}

# ==================================================================
# IAM 권한/역할
# ==================================================================
module "iam" {
    source = "./iam"

    role_name        = "std17-s3-role"
    role_description = "Allow Ec2 Instance to call AWS services on your behalf"
    policy_arn        = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

    tags = {
        Name = "std17-s3-role"
    }
}

# ==================================================================
# 4계층: alb (network, security, storage에 의존)
# www.sy99.cloud 진입점, nginx 타겟그룹/리스너/리스너규칙/Route53 소유
# ==================================================================
module "alb" {
    source = "./alb"

    vpc_id             = module.network.vpc_id
    public_subnet_ids  = module.network.public_subnet_ids
    security_group_id  = module.security.alb_sg_id

    domain_name         = "www.sy99.cloud"
    hosted_zone_id      = data.aws_route53_zone.std17_zone.zone_id
    acm_certificate_arn = data.aws_acm_certificate.std17_cert.arn
    domain_bucket_name  = "www.sy99.cloud"   # domain_website_endpoint 대신

    depends_on = [module.network, module.security, module.storage]
}

# ==================================================================
# 3계층: compute (network, security, storage, alb에 의존)
# ==================================================================
module "compute" {
    source = "./compute"

    vpc_id              = module.network.vpc_id
    private_subnet_ids  = module.network.private_subnet_ids
    security_group_id   = module.security.test_sg_id
    key_name            = var.key_name

    iam_instance_profile = module.iam.instance_profile_name

    target_group_arn = module.alb.nginx_target_group_arn

    route_table_ids = [
        module.network.default_rt_id,
        module.network.public_rt_id,
        module.network.private_rt_id
    ]

    depends_on = [module.network, module.security, module.storage, module.alb, module.iam]
}

# ==================================================================
# api: API Gateway (storage에 의존 - S3 웹사이트 엔드포인트 필요)
# ==================================================================
module "api" {
    source = "./api"

    domain_website_endpoint = module.storage.domain_website_endpoint

    depends_on = [module.storage]
}