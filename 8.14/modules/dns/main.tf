# ==================================================================
# Route53 프라이빗 호스팅 영역
# ==================================================================
resource "aws_route53_zone" "std17_private_zone" {
  name = var.zone_name

  vpc {
    vpc_id = var.vpc_id
  }

  comment = "std17 프라이빗 호스팅 영역 (VPC 내부 전용)"

  tags = { Name = "std17-private-zone" }
}

# ==================================================================
# NLB 레코드 (Alias) - mysql.std17.internal 등으로 NLB에 접근
# ==================================================================
resource "aws_route53_record" "std17_nlb_record" {
  zone_id = aws_route53_zone.std17_private_zone.zone_id
  name    = "mysql.${var.zone_name}"
  type    = "A"

  alias {
    name                   = var.nlb_dns_name
    zone_id                = var.nlb_zone_id
    evaluate_target_health = true
  }
}

# ==================================================================
# EC2 레코드 (A) - ec2.std17.internal -> 고정 프라이빗 IP
# ==================================================================
resource "aws_route53_record" "std17_ec2_record" {
  zone_id = aws_route53_zone.std17_private_zone.zone_id
  name    = "ec2.${var.zone_name}"
  type    = "A"
  ttl     = 300
  records = [var.ec2_private_ip]
}