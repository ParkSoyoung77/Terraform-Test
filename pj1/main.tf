# ==================================================================
# 1계층: network
# ==================================================================
module "network" {
    source = "./modules/network"

    azs = var.azs
}

# ==================================================================
# 2계층: security (network에 의존)
# ==================================================================
module "security" {
    source = "./modules/security"

    vpc_id = module.network.vpc_id
}

# ==================================================================
# 3계층: compute (network, security에 의존)
# ==================================================================
module "compute" {
    source = "./modules/compute"

    vpc_id              = module.network.vpc_id
    public_subnet_ids   = module.network.public_subnet_ids
    private_subnet_ids  = module.network.private_subnet_ids
    security_group_id   = module.security.test_sg_id
    key_name            = var.key_name

    depends_on = [module.network, module.security]
}

# ==================================================================
# 4계층: database (network, security에 의존)
# ==================================================================
module "database" {
    source = "./modules/database"

    private_subnet_ids = module.network.private_subnet_ids
    security_group_id  = module.security.test_sg_id
    db_password        = var.db_password

    depends_on = [module.network, module.security]
}

# ==================================================================
# storage: S3 (독립적, 다른 모듈과 의존관계 없음)
# ==================================================================
module "storage" {
    source = "./modules/storage"
}

# ==================================================================
# api: API G/W (독립적, 다른 모듈과 의존관계 없음)
# ==================================================================
module "api" {
    source = "./modules/api"

    s3_website_endpoint  = "http://std17-s3-bucket.s3-website-us-west-1.amazonaws.com"
    lambda_function_arn  = "arn:aws:lambda:us-west-1:925047940866:function:test2"

    depends_on = [module.storage]
}