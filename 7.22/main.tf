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

    vpc_id      = module.network.vpc_id
}

# ==================================================================
# 3계층: compute (network, security에 의존)
# ==================================================================
module "compute" {
    source = "./modules/compute"

    vpc_id              = module.network.vpc_id
    public_subnet_ids   = module.network.public_subnet_ids
    private_subnet_ids   = module.network.private_subnet_ids
    security_group_id   = module.security.test_sg_id
    key_name            = var.key_name

    # iam_instance_profile = module.iam.instance_profile_name

    route_table_ids = [
        module.network.default_rt_id,
        module.network.public_rt_id,
        module.network.private_rt_id
    ]

    depends_on = [module.network, module.security]
}

# ==================================================================
# storage: S3 (독립적, 다른 모듈과 의존관계 없음)
# ==================================================================
module "storage" {
    source = "./modules/storage"
}

# ==================================================================
# IAM 권한/역할
# ==================================================================
module "iam" {
  source = "./modules/iam"

  role_name        = "std17-s3-role"
  role_description = "Allow Ec2 Instance to call AWS services on your behalf"
  policy_arn        = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

  tags = {
    Name = "std17-s3-role"
  }
}