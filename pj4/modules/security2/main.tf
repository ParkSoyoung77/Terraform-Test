resource "aws_security_group" "std17_db_sg" {
    name        = "std17-db-sg"
    vpc_id      = var.vpc_id
    description = "Allow RDS MySQL access from VPC1 (Lambda) via Peering + RDS Proxy self"

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = var.allowed_cidr_blocks
        description = "MySQL from VPC1 via Peering"
    }

    # RDS Proxy와 RDS 인스턴스가 같은 SG를 공유하므로 self-reference 필수
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        self        = true  # RDS Proxy -> RDS (self)
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-db-sg" }
}