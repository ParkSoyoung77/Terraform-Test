# test-sg
resource "aws_security_group" "std17_test_sg" {
    name        = "std17-test-sg"
    vpc_id      = var.vpc_id
    description = "Test SG - ICMP, SSH, MySQL/Aurora, HTTP, HTTPS, 8080"

    # ICMP (IPv4 전용)
    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "ICMP IPv4"
    }

    # SSH
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH"
        self        = true
    }

    # MySQL/Aurora
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        self        = true
        cidr_blocks = ["0.0.0.0/0"]
        description = "MySQL/Aurora"
    }

    # HTTP
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP"
    }

    # HTTPS
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS"
    }

    # TCP 8080
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "TCP 8080"
    }

        # NFS
    ingress {
        from_port   = 2049
        to_port     = 2049
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "NFS"
    }

    # TCP 8000
    ingress {
        from_port   = 8000
        to_port     = 8000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "TCP 8000"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-test-sg" }
}

# db_sg
resource "aws_security_group" "std17_db_sg" {
  name        = "std17-db-sg"
  vpc_id      = var.vpc_id
  description = "RDS MySQL access from app tier"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.std17_test_sg.id]  # EC2 SG에서만 접근 허용
    description     = "MySQL from EC2"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "std17-db-sg" }
}