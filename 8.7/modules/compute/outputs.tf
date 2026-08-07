output "public_ec2_id" {
    value = aws_instance.std17_public_ec2.id
}

output "s3_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = aws_vpc_endpoint.std17_gw_endpoint.id
}

output "eni_id" {
  description = "std17-public-eni의 ID"
  value       = aws_network_interface.std17_public_eni.id
}

output "primary_private_ip" {
  value = var.primary_private_ip
}

output "secondary_private_ip" {
  value = var.secondary_private_ip
}

output "public_eip" {
  description = "EC2에 연결된 EIP 퍼블릭 주소"
  value       = aws_eip.std17_public_ec2_eip.public_ip
}