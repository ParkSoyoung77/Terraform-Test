# vpc
resource "aws_vpc" "std17_db_vpc" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = "std17-db-vpc"
    }
}

resource "aws_default_route_table" "std17_db_vpc_default_rt" {
    default_route_table_id = aws_vpc.std17_db_vpc.default_route_table_id

    tags = {
        Name = "std17-db-vpc-default-rt"
    }
}

# ==================================================================
# db-vpc private subnet (2개) → 10.0.10.0/26, 10.0.10.64/26
resource "aws_subnet" "std17_private_subnets2" {
    count             = 2
    vpc_id            = aws_vpc.std17_db_vpc.id
    cidr_block        = cidrsubnet(var.vpc2_cidr, 2, count.index) # index 0,1
    availability_zone = var.azs[count.index]

    tags = { Name = "std17-private${count.index + 1}-subnet2" }
}

# 프라이빗 라우팅 테이블
resource "aws_route_table" "std17_vpc_private_rt2" {
    vpc_id = aws_vpc.std17_db_vpc.id

    tags = { Name = "std17-vpc-private-rt2" }
}

resource "aws_route_table_association" "std17_vpc_private_rt_assoc2" {
    count          = 2
    route_table_id = aws_route_table.std17_vpc_private_rt2.id
    subnet_id      = aws_subnet.std17_private_subnets2[count.index].id
}

# ==================================================================
# Secrets Manager Interface VPC Endpoint
# (완전 격리형 VPC라 IGW/NAT가 없음 → RDS Proxy가 여기로만 시크릿을 조회)
# ==================================================================
resource "aws_security_group" "std17_secretsmanager_endpoint_sg" {
    name        = "std17-secretsmanager-endpoint-sg"
    vpc_id      = aws_vpc.std17_db_vpc.id
    description = "Allow HTTPS from DB VPC to Secrets Manager endpoint"

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [var.vpc2_cidr]
        description = "HTTPS from DB VPC"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-secretsmanager-endpoint-sg" }
}

resource "aws_vpc_endpoint" "std17_secretsmanager" {
    vpc_id              = aws_vpc.std17_db_vpc.id
    service_name         = "com.amazonaws.${var.aws_region}.secretsmanager"
    vpc_endpoint_type    = "Interface"
    subnet_ids            = aws_subnet.std17_private_subnets2[*].id
    security_group_ids    = [aws_security_group.std17_secretsmanager_endpoint_sg.id]
    private_dns_enabled   = true

    tags = { Name = "std17-secretsmanager-endpoint" }
}