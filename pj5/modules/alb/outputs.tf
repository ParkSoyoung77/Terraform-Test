output "alb_dns_name" {
    value = aws_lb.std17_alb.dns_name
}

output "alb_zone_id" {
    value = aws_lb.std17_alb.zone_id
}

output "target_group_arn" {
    value = aws_lb_target_group.std17_web_tg.arn
}

output "certificate_arn" {
    value = aws_acm_certificate_validation.std17.certificate_arn
}