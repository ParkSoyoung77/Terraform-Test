output "db_instance_id" {
    value = aws_db_instance.std17_mysql_rds.id
}

output "db_endpoint" {
    value = aws_db_instance.std17_mysql_rds.endpoint
}

output "db_address" {
    description = "포트가 붙지 않은 순수 호스트 주소 (Lambda DB_HOST용)"
    value       = aws_db_instance.std17_mysql_rds.address
}

output "db_subnet_group_name" {
    value = aws_db_subnet_group.std17_mysql_private_subnet_group.name
}

output "master_user_secret_arn" {
    description = "Secrets Manager ARN (Lambda DB_SECRET_NAME용)"
    value       = aws_db_instance.std17_mysql_rds.master_user_secret[0].secret_arn
}