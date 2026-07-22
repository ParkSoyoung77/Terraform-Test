# /html1 -> S3 REST 엔드포인트(path-style, HTTPS)로 302 리다이렉트
resource "aws_lb_listener_rule" "std17_html1_redirect" {
    listener_arn = aws_lb_listener.std17_alb_443_listener.arn
    priority     = 10

    action {
        type = "redirect"

        redirect {
            host        = "s3.${var.aws_region}.amazonaws.com"
            path        = "/${var.domain_bucket_name}/html1.html"
            protocol    = "HTTPS"
            status_code = "HTTP_302"
        }
    }

    condition {
        path_pattern {
            values = ["/html1", "/html1*"]
        }
    }
}

# /html2 -> S3 REST 엔드포인트(path-style, HTTPS)로 302 리다이렉트
resource "aws_lb_listener_rule" "std17_html2_redirect" {
    listener_arn = aws_lb_listener.std17_alb_443_listener.arn
    priority     = 20

    action {
        type = "redirect"

        redirect {
            host        = "s3.${var.aws_region}.amazonaws.com"
            path        = "/${var.domain_bucket_name}/html2.html"
            protocol    = "HTTPS"
            status_code = "HTTP_302"
        }
    }

    condition {
        path_pattern {
            values = ["/html2", "/html2*"]
        }
    }
}