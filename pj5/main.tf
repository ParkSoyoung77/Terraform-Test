# ==================================================================
# 0: iam
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

    vpc_id              = module.network.vpc_id
    vpc_cidr            = module.network.vpc_cidr
    private_subnet_ids  = module.network.private_subnet_ids

    depends_on = [module.network]
}

# ==================================================================
# 3: secrets (독립적)
# ==================================================================
module "secrets" {
    source = "./modules/secrets"

    db_name = var.db_name
}

# ==================================================================
# 4: alb (network, security에 의존) - ACM 인증서 포함
# ==================================================================
module "alb" {
    source = "./modules/alb"

    vpc_id             = module.network.vpc_id
    public_subnet_ids  = module.network.public_subnet_ids
    alb_sg_id          = module.security.alb_sg_id
    domain_name        = var.domain_name

    depends_on = [module.network, module.security]
}

# ==================================================================
# 5: compute (network, security, iam에 의존)
# ==================================================================
module "compute" {
    source = "./modules/compute"

    vpc_id                 = module.network.vpc_id
    private_subnet_ids     = module.network.private_subnet_ids
    ecs_general_sg_id      = module.security.ecs_general_sg_id
    ecs_db_sg_id           = module.security.ecs_db_sg_id
    ecs_instance_profile   = module.iam.ecs_instance_profile_name
    ecs_ami_id             = data.aws_ssm_parameter.ecs_ami.value
    general_instance_type  = var.general_instance_type
    db_instance_type       = var.db_instance_type
    general_desired_count  = var.general_desired_count

    depends_on = [module.network, module.security, module.iam]
}

# ==================================================================
# 6: ecs (compute, alb, secrets, iam에 의존)
# ==================================================================
module "ecs" {
    source = "./modules/ecs"

    aws_region                    = var.aws_region
    account_id                    = data.aws_caller_identity.current.account_id
    vpc_id                        = module.network.vpc_id
    cluster_name                  = module.compute.cluster_name
    target_group_arn              = module.alb.target_group_arn
    execution_role_arn            = module.iam.task_execution_role_arn
    execution_role_name           = module.iam.task_execution_role_name
    mysql_credentials_secret_arn  = module.secrets.mysql_credentials_secret_arn
    general_desired_count         = var.general_desired_count

    depends_on = [module.compute, module.alb, module.secrets, module.iam]
}

# ==================================================================
# 7: dns (alb에 의존) - Route53 A 별칭 레코드
# ==================================================================
module "dns" {
    source = "./modules/dns"

    domain_name    = var.domain_name
    alb_dns_name   = module.alb.alb_dns_name
    alb_zone_id    = module.alb.alb_zone_id

    depends_on = [module.alb]
}

# ==================================================================
# 8: budget - 비용 산정
# ==================================================================
module "budget" {
    source = "./modules/budget"

    alert_email = var.alert_email
}