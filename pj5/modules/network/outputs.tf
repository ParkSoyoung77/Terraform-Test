output "vpc_id" {
    value = aws_vpc.std17_vpc.id
}

output "vpc_cidr" {
    value = aws_vpc.std17_vpc.cidr_block
}

output "public_subnet_ids" {
    value = aws_subnet.std17_public_subnets[*].id
}

output "private_subnet_ids" {
    value = aws_subnet.std17_private_subnets[*].id
}