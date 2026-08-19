output "web_service_name" {
    value = aws_ecs_service.std17_web.name
}

output "db_service_name" {
    value = aws_ecs_service.std17_db.name
}