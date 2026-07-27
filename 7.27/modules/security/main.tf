# ==================================================================
# ALB 전용 SG (퍼블릭 대상, 80/443만 개방)
# ==================================================================
resource "aws_security_group" "std17_alb_sg" {
    name        = "std17-alb-sg"
    vpc_id      = var.vpc_id
    description = "ALB SG - HTTP/HTTPS from internet"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP"
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-alb-sg" }
}

# ==================================================================
# test-sg: 80은 ALB SG에서만, SSH/3306은 self만 유지
# ==================================================================
resource "aws_security_group" "std17_test_sg" {
    name        = "std17-test-sg"
    vpc_id      = var.vpc_id
    description = "Test SG - ICMP, SSH, MySQL/Aurora, HTTP(from ALB only), 8080"

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "ICMP IPv4"
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        self        = true
        description = "SSH (same-SG only)"
    }

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        self        = true
        description = "MySQL/Aurora (same-SG only)"
    }

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [aws_security_group.std17_alb_sg.id]
        description     = "HTTP from ALB only"
    }

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