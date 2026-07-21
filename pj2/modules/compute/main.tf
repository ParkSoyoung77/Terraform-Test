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

# HTTP -> HTTPS 강제 리다이렉트 (요구사항 7)
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

# HTTPS 리스너: 기본은 nginx(ASG)로 forward (요구사항 3, 7)
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

# /index.html -> S3 REST 엔드포인트(path-style, HTTPS)로 302 리다이렉트 (요구사항 4)
resource "aws_lb_listener_rule" "std17_index_html_redirect" {
    listener_arn = aws_lb_listener.std17_alb_443_listener.arn
    priority     = 10

    action {
        type = "redirect"

        redirect {
            host        = "s3.${var.aws_region}.amazonaws.com"
            path        = "/${var.domain_name}/index.html"
            protocol    = "HTTPS"
            status_code = "HTTP_302"
        }
    }

    condition {
        path_pattern {
            values = ["/index.html"]
        }
    }
}

# /api, /api/* -> API Gateway로 302 리다이렉트 (요구사항 6)
resource "aws_lb_listener_rule" "std17_api_redirect" {
    listener_arn = aws_lb_listener.std17_alb_443_listener.arn
    priority     = 20

    action {
        type = "redirect"

        redirect {
            host        = var.api_gateway_domain
            path        = "/api"
            protocol    = "HTTPS"
            status_code = "HTTP_302"
        }
    }

    condition {
        path_pattern {
            values = ["/api", "/api/*"]
        }
    }
}

# www.sy99.cloud -> ALB (진입점)
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