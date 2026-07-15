output "test_sg_id" {
    value = aws_security_group.std17_test_sg.id
}

output "nat_sg_id" {
  value = aws_security_group.std17_nat_sg.id
}

output "mysql_master_secret_arn" {
  value = aws_secretsmanager_secret.mysql_master.arn
}