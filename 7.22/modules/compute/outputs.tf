output "public_ec2_id" {
    value = aws_instance.std17_public_ec2.id
}

output "amazon_ec2_id" {
    value = aws_instance.std17_amazon_ec2.id
}