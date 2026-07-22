output "public_ec2_id" {
    value = aws_instance.std17_public_ec2.id
}

# output "private_ec2_id" {
#     value = aws_instance.std17_private_ec2.id
# }

# output "target_group_arn" {
#     value = aws_lb_target_group.std17_80_tg.arn
# }

# output "alb_arn" {
#     value = aws_lb.std17_alb_80.arn
# }

# output "alb_dns_name" {
#     value = aws_lb.std17_alb_80.dns_name
# }

# output "eice_id" {
#     value = aws_ec2_instance_connect_endpoint.std17_eice.id
# }