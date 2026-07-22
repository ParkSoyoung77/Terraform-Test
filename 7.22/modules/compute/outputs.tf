output "public_ec2_id" {
    value = aws_instance.std17_public_ec2.id
}

# output "amazon_ec2_id" {
#     value = aws_instance.std17_amazon_ec2.id
# }

# output "s3_endpoint_id" {
#   description = "S3 Gateway VPC endpoint ID"
#   value       = aws_vpc_endpoint.std17_gw_endpoint.id
# }

# output "interface_endpoint_id" {
#   description = "Interface VPC endpoint ID"
#   value       = aws_vpc_endpoint.std17_interface_endpoint.id
# }

# output "eice_id" {
#     value = aws_ec2_instance_connect_endpoint.std17_eice.id
# }