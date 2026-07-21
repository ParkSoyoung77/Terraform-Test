output "vpc2_id" {
    value = aws_vpc.std17_vpc2.id
}

output "public_subnet2_ids" {
    value = aws_subnet.std17_public_subnets2[*].id
}

output "private_subnet2_ids" {
    value = aws_subnet.std17_private_subnets2[*].id
}

output "igw2_id" {
    value = aws_internet_gateway.std17_vpc2_igw.id
}

output "nat2_id" {
    value = aws_nat_gateway.std17_nat2.id
}

output "public_rt2_id" {
    value = aws_route_table.std17_vpc2_public_rt2.id
}

output "private_rt2_id" {
    value = aws_route_table.std17_vpc_private_rt2.id
}