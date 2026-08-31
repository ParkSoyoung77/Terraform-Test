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
# 3: compute (network, security, eks에 의존)
# ==================================================================
module "compute" {
    source = "./modules/compute"

    vpc_id             = module.network.vpc_id
    public_subnet_ids  = module.network.public_subnet_ids

    route_table_ids = [
        module.network.default_rt_id,
        module.network.public_rt_id,
        module.network.private_rt_id 
    ]

    depends_on = [module.network, module.security]
}

# ==================================================================
# 4: eks (network, storage에 의존)
# ==================================================================
module "eks" {
    source = "./modules/eks"

    vpc_id              = module.network.vpc_id
    private_subnet_ids  = module.network.private_subnet_ids
    s3_logs_bucket_arn  = module.storage.bucket_arn

    depends_on = [module.network, module.storage]   # module.compute 제거
}

# ==================================================================
# 5: storage: S3 (독립적, 다른 모듈과 의존관계 없음)
# ==================================================================
module "storage" {
    source = "./modules/storage"
}

# ==================================================================
# ubuntu-s3-sa 쿠버네티스 ServiceAccount (IRSA 연결)
# ==================================================================
resource "kubernetes_service_account" "std17_ubuntu_s3_sa" {
    metadata {
        name      = "ubuntu-s3-sa"
        namespace = "default"

        annotations = {
            "eks.amazonaws.com/role-arn" = module.eks.nginx_s3_role_arn
        }
    }

    depends_on = [module.eks]
}