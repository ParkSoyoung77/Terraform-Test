# # ALB
# resource "aws_security_group" "std17_alb_sg" {
#     name        = "std17-alb-sg"
#     vpc_id      = var.vpc_id
#     description = "ALB - HTTP/HTTPS from internet"

#     ingress {
#         from_port   = 80
#         to_port     = 80
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     ingress {
#         from_port   = 443
#         to_port     = 443
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     egress {
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     tags = { Name = "std17-alb-sg" }
# }

# ECS general 노드 (nginx+fastapi) - ALB에서만 접근 가능
resource "aws_security_group" "std17_ecs_general_sg" {
    name        = "std17-ecs-general-sg"
    vpc_id      = var.vpc_id
    description = "ECS general nodes - dynamic port mapping from ALB"

    ingress {
        from_port       = 32768
        to_port         = 65535
        protocol        = "tcp"
        security_groups = [aws_security_group.std17_alb_sg.id]
        description     = "ALB - ECS dynamic host port (bridge mode)"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-ecs-general-sg" }
}

# ECS db 노드 (mysql) - general 노드에서만 접근 가능
resource "aws_security_group" "std17_ecs_db_sg" {
    name        = "std17-ecs-db-sg"
    vpc_id      = var.vpc_id
    description = "ECS db node - MySQL from general nodes only"

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = [aws_security_group.std17_ecs_general_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-ecs-db-sg" }
}

# VPC 엔드포인트(ECR api/dkr) - VPC 내부에서만 443
resource "aws_security_group" "std17_vpce_sg" {
    name        = "std17-vpce-sg"
    vpc_id      = var.vpc_id
    description = "Interface VPC Endpoint - HTTPS from VPC CIDR"

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-vpce-sg" }
}

# ==================================================================
# ECR Interface Endpoint 2개 (이전에 SG만 만들고 빠졌던 부분 - 추가함)
# ==================================================================
resource "aws_vpc_endpoint" "std17_ecr_api" {
    vpc_id              = var.vpc_id
    service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = var.private_subnet_ids
    security_group_ids  = [aws_security_group.std17_vpce_sg.id]
    private_dns_enabled = true

    tags = { Name = "std17-ecr-api-endpoint" }
}

resource "aws_vpc_endpoint" "std17_ecr_dkr" {
    vpc_id              = var.vpc_id
    service_name        = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
    vpc_endpoint_type   = "Interface"
    subnet_ids          = var.private_subnet_ids
    security_group_ids  = [aws_security_group.std17_vpce_sg.id]
    private_dns_enabled = true

    tags = { Name = "std17-ecr-dkr-endpoint" }
}

data "aws_region" "current" {}