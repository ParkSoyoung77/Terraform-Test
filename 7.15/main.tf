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
    nat_sg_id           = module.security.nat_sg_id
    key_name            = var.key_name

    depends_on = [module.network, module.security]
}

resource "aws_route" "std17_private_default_route" {
    route_table_id         = module.network.private_rt_id
    destination_cidr_block = "0.0.0.0/0"
    network_interface_id   = module.compute.nat_network_interface_id

    depends_on = [module.network, module.compute]
}

# ==================================================================
# 4계층: database (network, security에 의존)
# ==================================================================
module "database" {
    source = "./modules/database"

    private_subnet_ids = module.network.private_subnet_ids
    security_group_id  = module.security.test_sg_id
    db_secret_arn = module.security.mysql_master_secret_arn

    depends_on = [module.network, module.security]
}

# ==================================================================
# storage: S3 (독립적, 다른 모듈과 의존관계 없음)
# ==================================================================
module "storage" {
    source = "./modules/storage"
}
