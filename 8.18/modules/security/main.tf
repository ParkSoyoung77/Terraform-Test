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
    # MySQL 클라이언트 통신
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        self        = true
        cidr_blocks = ["0.0.0.0/0"]
        description = "MySQL/Aurora"
    }

    # MySQL Shell X Protocol 포트
    ingress {
        from_port   = 33060
        to_port     = 33060
        protocol    = "tcp"
        self        = true
        cidr_blocks = ["0.0.0.0/0"]
        description = "MySQL/Aurora"
    }

    # InnoDB Cluster 그룹 통신
    ingress {
        from_port   = 33061
        to_port     = 33061
        protocol    = "tcp"
        self        = true
        cidr_blocks = ["0.0.0.0/0"]
        description = "MySQL/Aurora"
    }

    # Group Replication 내부 통신
    ingress {
        from_port   = 33062
        to_port     = 33062
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

# router-sg
resource "aws_security_group" "std17_router_sg" {
    name        = "std17-router-sg"
    vpc_id      = var.vpc_id
    description = "MySQL Router - R/W(6446), Read-Only(6447)"

    # MySQL Router - Read/Write (Primary)
    ingress {
        from_port   = 6446
        to_port     = 6446
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "MySQL Router Write & Read"
    }

    # MySQL Router - Read Only (Secondary)
    ingress {
        from_port   = 6447
        to_port     = 6447
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "MySQL Router Read Only"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-router-sg" }
}

# swarm-sg
resource "aws_security_group" "std17_swarm_sg" {
    name        = "std17-swarm-sg"
    vpc_id      = var.vpc_id
    description = "Docker Swarm - Cluster management, Discovery, Overlay network"

    # 클러스터 관리 통신용
    ingress {
        from_port   = 2377
        to_port     = 2377
        protocol    = "tcp"
        self        = true
        description = "Swarm cluster management communication"
    }

    # 노드간 네트워크 발견(discovery)용 - TCP
    ingress {
        from_port   = 7946
        to_port     = 7946
        protocol    = "tcp"
        self        = true
        description = "Node discovery (TCP)"
    }

    # 노드간 네트워크 발견(discovery)용 - UDP
    ingress {
        from_port   = 7946
        to_port     = 7946
        protocol    = "udp"
        self        = true
        description = "Node discovery (UDP)"
    }

    # 오버레이 네트워크(overlay network)용 - UDP (VXLAN)
    ingress {
        from_port   = 4789
        to_port     = 4789
        protocol    = "udp"
        self        = true
        description = "Overlay network traffic (VXLAN)"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-swarm-sg" }
}