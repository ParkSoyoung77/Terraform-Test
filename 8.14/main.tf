# ==================================================================
# 0: iam (다른 모듈에 앞서 역할부터 생성)
# ==================================================================
module "iam" {
    source = "./modules/iam"
}

# ==================================================================
# 1: network
# ==================================================================
module "network" {
    source = "./modules/network"

    azs = var.azs
}

# ==================================================================
# 2: security (network에 의존)
# ==================================================================
module "security" {
    source = "./modules/security"

    vpc_id = module.network.vpc_id
}

# ==================================================================
# 3: compute (network, security에 의존)
# ==================================================================
module "compute" {
    source = "./modules/compute"

    vpc_id              = module.network.vpc_id
    public_subnet_ids  = module.network.public_subnet_ids
    security_group_id   = module.security.test_sg_id
    key_name            = var.key_name
    iam_instance_profile = module.iam.fullaccess_instance_profile_name

    route_table_ids = [
        module.network.default_rt_id,
        module.network.public_rt_id
    ]

    depends_on = [module.network, module.security, module.storage, module.iam]
}

# ==================================================================
# 4: storage: S3 (독립적, 다른 모듈과 의존관계 없음)
# ==================================================================
module "storage" {
    source = "./modules/storage"
}

# ==================================================================
# 5: nlb (network, security, compute에 의존)
# ==================================================================
module "nlb" {
    source = "./modules/nlb"

    vpc_id             = module.network.vpc_id
    subnet_ids         = module.network.public_subnet_ids
    security_group_id  = module.security.test_sg_id
    instance_id        = module.compute.public_ec2_id

    depends_on = [module.network, module.security, module.compute]
}

# ==================================================================
# 6: dns (Route53 프라이빗 호스팅 영역, nlb/compute에 의존)
# ==================================================================
module "dns" {
    source = "./modules/dns"

    vpc_id          = module.network.vpc_id
    nlb_dns_name    = module.nlb.nlb_dns_name
    nlb_zone_id     = module.nlb.nlb_zone_id
    ec2_private_ip  = module.compute.private_ip

    depends_on = [module.nlb, module.compute]
}