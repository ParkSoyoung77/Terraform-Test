output "test_sg_id" {
    value = aws_security_group.std17_test_sg.id
}

output "router_sg_id" {
    description = "MySQL Router 전용 보안그룹 ID"
    value       = aws_security_group.std17_router_sg.id
}

output "swarm_sg_id" {
    description = "Docker Swarm 전용 보안그룹 ID"
    value       = aws_security_group.std17_swarm_sg.id
}

output "ecr_endpoint_sg_id" {
    description = "ECR 엔드포인트 전용 보안그룹 ID"
    value       = aws_security_group.std17_swarm_sg.id
}