output "public_ec2_id" {
    value = aws_instance.std17_public_ec2.id
}

# output "amazon_ec2_id" {
#     value = aws_instance.std17_amazon_ec2.id
# }

output "s3_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = aws_vpc_endpoint.std17_gw_endpoint.id
}