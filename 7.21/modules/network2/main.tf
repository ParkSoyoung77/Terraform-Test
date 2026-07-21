# vpc
resource "aws_vpc" "std17_vpc2" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = "std17-vpc2"
    }
}

resource "aws_default_route_table" "std17_vpc2_default_rt" {
    default_route_table_id = aws_vpc.std17_vpc2.default_route_table_id

    tags = {
        Name = "std17-vpc2-default-rt"
    }
}

# ==================================================================

# public subnets
resource "aws_subnet" "std17_public_subnets2" {
    count                                        = 1
    vpc_id                                       = aws_vpc.std17_vpc2.id
    cidr_block                                   = "10.10.${count.index + 1}.0/24"
    availability_zone                            = var.azs[count.index]

    map_public_ip_on_launch                     = true
    enable_resource_name_dns_a_record_on_launch = true
    private_dns_hostname_type_on_launch         = "ip-name"

    tags = {
        Name = "std17-public${count.index + 1}-subnet2"
    }
}

# public rt
resource "aws_route_table" "std17_vpc2_public_rt2" {
    vpc_id = aws_vpc.std17_vpc2.id

    tags = {
        Name = "std17-vpc2-public-rt"
    }
}

resource "aws_route_table_association" "std17_vpc2_public_rt_assoc2" {
    count          = 1
    route_table_id = aws_route_table.std17_vpc2_public_rt2.id
    subnet_id      = aws_subnet.std17_public_subnets2[count.index].id
}

# ==================================================================

# private subnets
resource "aws_subnet" "std17_private_subnets2" {
    count             = 1
    vpc_id            = aws_vpc.std17_vpc2.id
    cidr_block        = "10.10.${count.index + 11}.0/24"
    availability_zone = var.azs[count.index]

    tags = { Name = "std17-private${count.index + 1}-subnet2" }
}

# 프라이빗 라우팅 테이블
resource "aws_route_table" "std17_vpc_private_rt2" {
    vpc_id = aws_vpc.std17_vpc2.id

    tags = { Name = "std17-vpc-private-rt" }
}

resource "aws_route_table_association" "std17_vpc_private_rt_assoc2" {
    count          = 1
    route_table_id = aws_route_table.std17_vpc_private_rt2.id
    subnet_id      = aws_subnet.std17_private_subnets2[count.index].id
}