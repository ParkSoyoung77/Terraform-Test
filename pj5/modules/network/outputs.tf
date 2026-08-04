output "vpc_id" {
    value = aws_vpc.std17_vpc.id
}

output "vpc_cidr" {
    value = aws_vpc.std17_vpc.cidr_block
}

output "default_rt_id" {
    value = aws_default_route_table.std17_vpc_default_rt.id
}

output "public_subnet_ids" {
    value = aws_subnet.std17_public_subnets[*].id
}

output "igw_id" {
    value = aws_internet_gateway.std17_vpc_igw.id
}

output "public_rt_id" {
    value = aws_route_table.std17_vpc_public_rt.id
}
