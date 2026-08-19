output "ecs_instance_profile_name" {
    value = aws_iam_instance_profile.std17_ecs_instance_profile.name
}

output "task_execution_role_arn" {
    value = aws_iam_role.std17_task_execution_role.arn
}

output "task_execution_role_name" {
    value = aws_iam_role.std17_task_execution_role.name
}