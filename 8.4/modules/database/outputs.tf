output "db_instance_id" {
    value = aws_db_instance.std17_mysql_rds.id
}

output "db_endpoint" {
    value = aws_db_instance.std17_mysql_rds.endpoint
}

output "db_subnet_group_name" {
    value = aws_db_subnet_group.std17_db_private_subnet_group.name
}