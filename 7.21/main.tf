# ==================================================================
# 1계층: network
# ==================================================================
module "network" {
    source = "./modules/network"

    azs = var.azs
}

module "network2" {
    source = "./modules/network2"

    azs = var.azs
}

# ==================================================================
# 2계층: security (network에 의존)
# ==================================================================
module "security" {
    source = "./modules/security"

    vpc_id      = module.network.vpc_id
    db_username = var.db_username
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
