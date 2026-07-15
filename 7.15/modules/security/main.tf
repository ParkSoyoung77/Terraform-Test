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

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-test-sg" }
}

# nat-sg
resource "aws_security_group" "std17_nat_sg" {
    name        = "std17-nat-sg"
    vpc_id      = var.vpc_id
    description = "Security group for NAT Instance"

    # VPC 내부 전체 트래픽 허용 (기존 bash 스크립트의 authorize-security-group-ingress와 동일)
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.0.0.0/16"]
        description = "Allow all traffic from VPC CIDR"
    }

    # 전체 아웃바운드 허용 (명시적으로 선언 - import 대비)
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
    }

    tags = { Name  = "std17-nat-sg" }
}

# secret manager
resource "random_password" "mysql_master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "mysql_master" {
  name        = "std17-mysql-rds-secret"
  description = "std17-mysql-rds master credentials"

  tags = { Name = "std17-mysql-rds-secret" }
}

resource "aws_secretsmanager_secret_version" "mysql_master" {
  secret_id = aws_secretsmanager_secret.mysql_master.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.mysql_master_password.result
  })
}