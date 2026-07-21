output "public_ec2_id" {
    value = aws_instance.std17_public_ec2.id
}

output "target_group_arn" {
    value = aws_lb_target_group.std17_80_tg.arn
}

output "alb_arn" {
    value = aws_lb.std17_alb_80.arn
}

output "alb_dns_name" {
    value = aws_lb.std17_alb_80.dns_name
}
