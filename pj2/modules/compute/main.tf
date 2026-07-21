# ==================================================================
# ALB (인터넷 진입점, CloudFront origin) - 대상은 compute2의 ASG
# ==================================================================

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

resource "aws_lb" "std17_alb_80" {
    name               = "std17-alb-80"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [var.security_group_id]
    subnets            = var.public_subnet_ids

    tags = { Name = "std17-alb-80" }
}

resource "aws_lb_listener" "std17_alb_80_listener" {
    load_balancer_arn = aws_lb.std17_alb_80.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.std17_80_tg.arn
    }
}