output "private_ec2_id" {
    value = aws_instance.std17_private_ec2.id
}

output "s3_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = aws_vpc_endpoint.std17_gw_endpoint.id
}

output "asg_name" {
    value = aws_autoscaling_group.std17_asg.name
}

output "launch_template_id" {
    value = aws_launch_template.std17_lt.id
}

output "eice_id" {
    value = aws_ec2_instance_connect_endpoint.std17_eice.id
}