# ssh-sg
resource "aws_security_group" "std17_ssh_sg" {
    name = "std17-ssh-sg"
    vpc_id = aws_vpc.std17_vpc.id
    description = "Allow SSH Traffic"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0     
        to_port     = 0
        protocol    = "-1" 
        cidr_blocks = ["0.0.0.0/0"]
    }
  
  tags = { Name = "std17-ssh-sg" }
}

# http-sg
resource "aws_security_group" "std17_http_sg" {
    name = "std17-http-sg"
    vpc_id = aws_vpc.std17_vpc.id
    description = "Allow HTTP and HTTPS Traffic"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0     # 모든 포트
        to_port     = 0
        protocol    = "-1"  # 모든 프로토콜
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "std17-http-sg" }
}