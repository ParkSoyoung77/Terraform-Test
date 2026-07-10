output "availability_zone" {
    value       = data.aws_availability_zones.az.names
    description = "사용 가능한 가용영역 정보"
}

output "vpc_id" {
    value = aws_vpc.std17_vpc.id
}

output "public_subnets_id" {
    value = aws_subnet.std17_public_subnets[*].id
}

output "private_subnets_id" {
    value = aws_subnet.std17_private_subnets[*].id
}

output "igw_id" {
    value = aws_internet_gateway.std17_vpc_igw.id
}

output "test_sg_id" {
    value=aws_security_group.std17_test_sg.id
}

output "nat_id" {
    value = aws_nat_gateway.std17_nat.id
}
