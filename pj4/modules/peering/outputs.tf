output "peering_connection_id" {
  description = "VPC1(웹) - VPC2(DB) 간 VPC Peering Connection ID"
  value       = aws_vpc_peering_connection.std17_peering.id
}