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
# VPC연결: tgw
# ==================================================================
module "tgw" {
    source = "./modules/tgw"

    vpc1_id                      = module.network.vpc_id
    vpc1_subnet_ids              = module.network.private_subnet_ids
    vpc1_route_table_id          = module.network.private_rt_id
    vpc1_public_route_table_id   = module.network.public_rt_id
    vpc1_default_route_table_id  = module.network.default_rt_id
    vpc1_cidr                    = module.network.vpc_cidr

    vpc2_id                      = module.network2.vpc_id
    vpc2_subnet_ids              = module.network2.private_subnet_ids
    vpc2_route_table_id          = module.network2.private_rt_id
    vpc2_public_route_table_id   = module.network2.public_rt_id
    vpc2_default_route_table_id  = module.network2.default_rt_id
    vpc2_cidr                    = module.network2.vpc_cidr

    depends_on = [module.network, module.network2]
}