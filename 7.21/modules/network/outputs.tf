output "vpc_id" {
    value = aws_vpc.std17_vpc.id
}

output "public_subnet_ids" {
    value = aws_subnet.std17_public_subnets[*].id
}

output "private_subnet_ids" {
    value = aws_subnet.std17_private_subnets[*].id
}

output "db_private_subnet_ids"{
    value = aws_subnet.std17_db_private_subnets[*].id
}

output "igw_id" {
    value = aws_internet_gateway.std17_vpc_igw.id
}

output "nat_id" {
    value = aws_nat_gateway.std17_nat.id
}

output "public_rt_id" {
    value = aws_route_table.std17_vpc_public_rt.id
}

output "private_rt_id" {
    value = aws_route_table.std17_vpc_private_rt.id
}

output "db_pirvate_rt_id" {
    value = aws_route_table.std17_vpc_db_private_rt.id
}