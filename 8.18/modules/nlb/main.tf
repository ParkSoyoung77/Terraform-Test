# ==================================================================
# 대상 그룹 1: MySQL (TCP 3306)
# ==================================================================
resource "aws_lb_target_group" "std17_mysql_tg" {
  name        = "std17-mysql-tg"
  port        = 3306
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = "3306"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
  }

  tags = { Name = "std17-mysql-tg" }
}

resource "aws_lb_target_group_attachment" "std17_mysql_tg_attach" {
  target_group_arn = aws_lb_target_group.std17_mysql_tg.arn
  target_id        = var.instance_id
  port             = 3306
}

# ==================================================================
# 대상 그룹 2: SSH (TCP 22)
# ==================================================================
resource "aws_lb_target_group" "std17_ssh_tg" {
  name        = "std17-ssh-tg"
  port        = 22
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = "22"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
  }

  tags = { Name = "std17-ssh-tg" }
}

resource "aws_lb_target_group_attachment" "std17_ssh_tg_attach" {
  target_group_arn = aws_lb_target_group.std17_ssh_tg.arn
  target_id        = var.instance_id
  port             = 22
}

# ==================================================================
# NLB (내부, IPv4)
# ==================================================================
resource "aws_lb" "std17_nlb" {
  name               = "std17-nlb"
  internal           = true
  load_balancer_type = "network"
  ip_address_type    = "ipv4"

  subnets         = var.subnet_ids
  security_groups = [var.security_group_id]

  tags = { Name = "std17-nlb" }
}

# ==================================================================
# 리스너 1: TCP 3306 -> mysql-tg
# ==================================================================
resource "aws_lb_listener" "std17_nlb_listener_3306" {
  load_balancer_arn = aws_lb.std17_nlb.arn
  port              = 3306
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.std17_mysql_tg.arn
  }
}

# ==================================================================
# 리스너 2: TCP 22 -> ssh-tg
# ==================================================================
resource "aws_lb_listener" "std17_nlb_listener_22" {
  load_balancer_arn = aws_lb.std17_nlb.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.std17_ssh_tg.arn
  }
}