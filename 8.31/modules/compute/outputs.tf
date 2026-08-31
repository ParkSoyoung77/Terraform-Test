output "public_ec2_id" {
  description = "EC2 인스턴스 ID 리스트"
  value       = aws_instance.std17_public_ec2[*].id
}

output "s3_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = aws_vpc_endpoint.std17_gw_endpoint.id
}

output "eni_id" {
  description = "std17-public-eni ID 리스트"
  value       = aws_network_interface.std17_public_eni[*].id
}

output "public_eip" {
  description = "EC2에 연결된 EIP 퍼블릭 주소 리스트"
  value       = aws_eip.std17_public_ec2_eip[*].public_ip
}

output "private_ip" {
  description = "EC2의 고정 프라이빗 IP 리스트"
  value       = aws_instance.std17_public_ec2[*].private_ip
}
