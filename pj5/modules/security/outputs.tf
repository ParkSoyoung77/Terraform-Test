output "alb_sg_id" {
    value = aws_security_group.std17_alb_sg.id
}

output "ecs_general_sg_id" {
    value = aws_security_group.std17_ecs_general_sg.id
}

output "ecs_db_sg_id" {
    value = aws_security_group.std17_ecs_db_sg.id
}