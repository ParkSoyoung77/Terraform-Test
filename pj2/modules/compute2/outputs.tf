output "private_ec2_id" {
    value = aws_instance.std17_private_ec2.id
}

output "asg_name" {
    value = aws_autoscaling_group.std17_asg.name
}