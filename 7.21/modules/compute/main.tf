# ==================================================================
# EC2 인스턴스
# ==================================================================

resource "aws_instance" "std17_public_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 10
    volume_type            = "gp3"
    delete_on_termination  = true
  }

  key_name = var.key_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  # 유저데이터
  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y nginx mysql-client

systemctl enable nginx
systemctl start nginx
EOF

  user_data_replace_on_change = true

  tags = { Name = "std17-public-ec2" }
}

# ==================================================================
# ALB
# ==================================================================

# 1. 대상그룹
resource "aws_lb_target_group" "std17_80_tg" {
    name     = "std17-80-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = var.vpc_id

    slow_start           = 30
    deregistration_delay = 30

    health_check {
        path                = "/"
        protocol            = "HTTP"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
    }

    tags = { Name = "std17-80-tg" }
}

# 2. 대상 그룹 인스턴스 등록
# ASG가 target_group_arns로 자동 등록하므로 별도 attachment 불필요
resource "aws_lb_target_group_attachment" "std17_80_tg_attachment" {
    target_group_arn = aws_lb_target_group.std17_80_tg.arn
    target_id = aws_instance.std17_public_ec2.id
    port = 80
}

# 3. ALB 생성
resource "aws_lb" "std17_alb_80" {
  name               = "std17-alb-80"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  tags = { Name = "std17-alb-80" }
}

# 4. ALB 리스너 생성
resource "aws_lb_listener" "std17_alb_80_listener" {
  load_balancer_arn = aws_lb.std17_alb_80.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.std17_80_tg.arn
  }
}