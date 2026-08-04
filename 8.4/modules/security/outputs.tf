output "test_sg_id" {
    value = aws_security_group.std17_test_sg.id
}

output "db_sg_id" {
    description = "RDS용 보안그룹 ID"
    value       = aws_security_group.std17_db_sg.id
}