output "test_sg_id" {
    value = aws_security_group.std17_test_sg.id
}

output "db_sg_id" {
    description = "RDS용 보안그룹 ID"
    value       = aws_security_group.std17_db_sg.id
}

output "router_sg_id" {
    description = "MySQL Router 전용 보안그룹 ID"
    value       = aws_security_group.std17_router_sg.id
}