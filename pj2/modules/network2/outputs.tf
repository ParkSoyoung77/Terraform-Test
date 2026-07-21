output "vpc_id" {
    value = aws_vpc.std17_vpc2.id
}

output "vpc_cidr" {
    value = aws_vpc.std17_vpc2.cidr_block
}

output "default_rt_id" {
    value = aws_default_route_table.std17_vpc2_default_rt.id
}

output "public_subnet_ids" {
    value = aws_subnet.std17_public_subnets2[*].id
}

output "private_subnet_ids" {
    value = aws_subnet.std17_private_subnets2[*].id
}

output "public_rt_id" {
    value = aws_route_table.std17_vpc2_public_rt2.id    
}

output "private_rt_id" {
    value = aws_route_table.std17_vpc_private_rt2.id    
}

output "igw_id" {
    value = aws_internet_gateway.std17_vpc2_igw.id
}

output "nat_id" {
    value = aws_nat_gateway.std17_nat2.id
}