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

output "igw_id" {
    value = aws_internet_gateway.std17_vpc_igw.id
}

output "ssh_sg_id" {
    value= aws_security_group.std17_ssh_sg.id
}

output "http_sg_id" {
    value=aws_security_group.std17_http_sg.id
}

# output "ami_id" {
#     value=aws_ami_from_instance.std17_ami.id
# }

# output "lt_id" {
#     value=aws_launch_template.std17_lt.id
# }

output "cloudfront_id" {
  value = aws_cloudfront_distribution.std17_cdn.id
}

output "mysql_endpoint" {
  value = aws_db_instance.std17_mysql_rds.endpoint
}