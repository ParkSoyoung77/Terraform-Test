resource "aws_security_group" "std17_db_sg" {
    name        = "std17-db-sg"
    vpc_id      = var.vpc_id
    description = "RDS MySQL 접근 허용 (VPC1 Lambda -> TGW -> VPC2 RDS)"

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = var.allowed_cidr_blocks
        description = "MySQL from VPC1 via TGW"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-db-sg" }
}