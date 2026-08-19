# ------------------------------------------------------------
# ACM (이 ALB의 HTTPS 리스너 전용 인증서)
# ------------------------------------------------------------
data "aws_route53_zone" "std17" {
    name         = var.domain_name
    private_zone = false
}

resource "aws_acm_certificate" "std17" {
    domain_name       = var.domain_name
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }

    tags = { Name = "std17-acm-cert" }
}

resource "aws_route53_record" "std17_cert_validation" {
    for_each = {
        for dvo in aws_acm_certificate.std17.domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            type   = dvo.resource_record_type
            record = dvo.resource_record_value
        }
    }

    zone_id = data.aws_route53_zone.std17.zone_id
    name    = each.value.name
    type    = each.value.type
    records = [each.value.record]
    ttl     = 60
}

resource "aws_acm_certificate_validation" "std17" {
    certificate_arn         = aws_acm_certificate.std17.arn
    validation_record_fqdns = [for r in aws_route53_record.std17_cert_validation : r.fqdn]
}

# ------------------------------------------------------------
# ALB
# ------------------------------------------------------------
resource "aws_lb" "std17_alb" {
    name               = "std17-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [var.alb_sg_id]
    subnets            = var.public_subnet_ids

    tags = { Name = "std17-alb" }
}

resource "aws_lb_target_group" "std17_web_tg" {
    name        = "std17-web-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "instance"

    health_check {
        path                = "/"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 30
    }

    tags = { Name = "std17-web-tg" }
}

# HTTP -> HTTPS 리다이렉트
resource "aws_lb_listener" "std17_http" {
    load_balancer_arn = aws_lb.std17_alb.arn
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

resource "aws_lb_listener" "std17_https" {
    load_balancer_arn = aws_lb.std17_alb.arn
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    certificate_arn   = aws_acm_certificate_validation.std17.certificate_arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.std17_web_tg.arn
    }
}