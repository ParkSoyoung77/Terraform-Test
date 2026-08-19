data "aws_route53_zone" "std17" {
    name         = var.domain_name
    private_zone = false
}

resource "aws_route53_record" "std17_alb_alias" {
    zone_id = data.aws_route53_zone.std17.zone_id
    name    = var.domain_name
    type    = "A"

    alias {
        name                   = var.alb_dns_name
        zone_id                = var.alb_zone_id
        evaluate_target_health = true
    }
}