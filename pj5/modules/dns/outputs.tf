output "record_fqdn" {
    value = aws_route53_record.std17_alb_alias.fqdn
}