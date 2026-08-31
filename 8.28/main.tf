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

    vpc_id             = module.network.vpc_id
    public_subnet_ids  = module.network.public_subnet_ids
    ecr_endpoint_sg_id = module.security.ecr_endpoint_sg_id

    route_table_ids = [
        module.network.default_rt_id,
        module.network.public_rt_id,
        module.network.private_rt_id 
    ]

    depends_on = [module.network, module.security]
}

# ==================================================================
# 4: eks (network에 의존)
# 기존 main.tf 하단에 이 블록을 추가하세요.
# ==================================================================
module "eks" {
    source = "./modules/eks"

    vpc_id              = module.network.vpc_id
    private_subnet_ids  = module.network.private_subnet_ids

    # node_group_name     = "std17-ng-t3"
    # node_instance_types = ["t3.small"]
    # node_desired_size   = 2
    # node_min_size       = 1
    # node_max_size       = 3

    depends_on = [module.network]
}

# ==================================================================
# 5: storage: S3 (독립적, 다른 모듈과 의존관계 없음)
# ==================================================================
module "storage" {
    source = "./modules/storage"
}
