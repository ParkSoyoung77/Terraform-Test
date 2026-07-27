# ==================================================================
# 1: network
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
# 2: security (network에 의존)
# ==================================================================
module "security" {
    source = "./modules/security"

    vpc_id = module.network.vpc_id
}

# module "security2" {
#     source = "./modules/security2"

#     vpc2_id = module.network2.vpc2_id
# }

# ==================================================================
# 3: compute (network, security에 의존)
# ==================================================================
module "compute" {
    source = "./modules/compute"

    vpc_id              = module.network.vpc_id
    public_subnet_ids  = module.network.public_subnet_ids
    security_group_id   = module.security.test_sg_id
    key_name            = var.key_name

    depends_on = [module.network, module.security]
}