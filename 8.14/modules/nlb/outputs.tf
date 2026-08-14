output "nlb_id" {
  description = "NLB ID"
  value       = aws_lb.std17_nlb.id
}

output "nlb_arn" {
  description = "NLB ARN"
  value       = aws_lb.std17_nlb.arn
}

output "nlb_dns_name" {
  description = "NLB 내부 DNS 이름"
  value       = aws_lb.std17_nlb.dns_name
}

output "mysql_tg_arn" {
  description = "MySQL(3306) 대상그룹 ARN"
  value       = aws_lb_target_group.std17_mysql_tg.arn
}

output "ssh_tg_arn" {
  description = "SSH(22) 대상그룹 ARN"
  value       = aws_lb_target_group.std17_ssh_tg.arn
}