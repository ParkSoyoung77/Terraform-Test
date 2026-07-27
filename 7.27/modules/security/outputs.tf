output "test_sg_id" {
    value = aws_security_group.std17_test_sg.id
}

output "alb_sg_id" {
    value = aws_security_group.std17_alb_sg.id
}