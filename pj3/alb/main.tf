# ==================================================================
# ALB (인터넷 진입점) - 대상은 nginx ASG
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

# HTTP -> HTTPS 강제 리다이렉트 (요구사항 8)
resource "aws_lb_listener" "std17_alb_80_listener" {
    load_balancer_arn = aws_lb.std17_alb_80.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type = "redirect"

        redirect {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

# HTTPS 리스너: 기본은 nginx(ASG)로 forward (요구사항 5)
resource "aws_lb_listener" "std17_alb_443_listener" {
    load_balancer_arn = aws_lb.std17_alb_80.arn
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    certificate_arn   = var.acm_certificate_arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.std17_80_tg.arn
    }
}

# /html1 -> S3 웹사이트 엔드포인트의 html1.html로 리다이렉트 (요구사항 6)
resource "aws_lb_listener_rule" "std17_html1_redirect" {
    listener_arn = aws_lb_listener.std17_alb_443_listener.arn
    priority     = 10

    action {
        type = "redirect"

        redirect {
            host        = var.domain_website_endpoint
            path        = "/html1.html"
            port        = "80"
            protocol    = "HTTP"
            status_code = "HTTP_302"
        }
    }

    condition {
        path_pattern {
            values = ["/html1", "/html1*"]
        }
    }
}

# /html2 -> S3 웹사이트 엔드포인트의 html2.html로 리다이렉트 (요구사항 7)
resource "aws_lb_listener_rule" "std17_html2_redirect" {
    listener_arn = aws_lb_listener.std17_alb_443_listener.arn
    priority     = 20

    action {
        type = "redirect"

        redirect {
            host        = var.domain_website_endpoint
            path        = "/html2.html"
            port        = "80"
            protocol    = "HTTP"
            status_code = "HTTP_302"
        }
    }

    condition {
        path_pattern {
            values = ["/html2", "/html2*"]
        }
    }
}

# Route53: www.sy99.cloud -> ALB (진입점)
resource "aws_route53_record" "std17_www_alias" {
    zone_id = var.hosted_zone_id
    name    = var.domain_name
    type    = "A"

    alias {
        name                   = aws_lb.std17_alb_80.dns_name
        zone_id                = aws_lb.std17_alb_80.zone_id
        evaluate_target_health = true
    }
}