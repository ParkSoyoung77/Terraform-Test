output "zone_id" {
  description = "프라이빗 호스팅 영역 ID"
  value       = aws_route53_zone.std17_private_zone.zone_id
}

output "zone_name" {
  description = "프라이빗 호스팅 영역 도메인 이름"
  value       = aws_route53_zone.std17_private_zone.name
}

output "mysql_record_fqdn" {
  description = "MySQL(NLB) 접근용 FQDN"
  value       = aws_route53_record.std17_nlb_record.fqdn
}

output "ec2_record_fqdn" {
  description = "EC2 접근용 FQDN"
  value       = aws_route53_record.std17_ec2_record.fqdn
}