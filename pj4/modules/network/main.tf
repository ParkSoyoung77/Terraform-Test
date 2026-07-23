# vpc
resource "aws_vpc" "std17_vpc" {
    cidr_block           = var.vpc1_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = "std17-vpc"
    }
}

resource "aws_default_route_table" "std17_vpc_default_rt" {
    default_route_table_id = aws_vpc.std17_vpc.default_route_table_id

    tags = {
        Name = "std17-vpc-default-rt"
    }
}

# ==================================================================

# vpc1 public subnet (2개) → 10.0.0.0/26, 10.0.0.64/26
resource "aws_subnet" "std17_public_subnets" {
    count             = 2
    vpc_id            = aws_vpc.std17_vpc.id
    cidr_block        = cidrsubnet(var.vpc1_cidr, 2, count.index) # index 0,1
    availability_zone = var.azs[count.index]

    map_public_ip_on_launch                     = true
    enable_resource_name_dns_a_record_on_launch = true
    private_dns_hostname_type_on_launch         = "ip-name"

    tags = {
        Name = "std17-public${count.index + 1}-subnet"
    }
}

# IGW
resource "aws_internet_gateway" "std17_vpc_igw" {
    vpc_id = aws_vpc.std17_vpc.id
    tags = {
        Name = "std17-vpc-igw"
    }
}

# public rt
resource "aws_route_table" "std17_vpc_public_rt" {
    vpc_id = aws_vpc.std17_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.std17_vpc_igw.id
    }

    tags = {
        Name = "std17-vpc-public-rt"
    }
}

resource "aws_route_table_association" "std17_vpc_public_rt_assoc" {
    count          = 2
    route_table_id = aws_route_table.std17_vpc_public_rt.id
    subnet_id      = aws_subnet.std17_public_subnets[count.index].id
}

# ==================================================================

# vpc1 private subnet (2개) → 10.0.0.128/26, 10.0.0.192/26
resource "aws_subnet" "std17_private_subnets" {
    count             = 2
    vpc_id            = aws_vpc.std17_vpc.id
    cidr_block        = cidrsubnet(var.vpc1_cidr, 2, count.index + 2) # index 2,3
    availability_zone = var.azs[count.index]

    tags = { Name = "std17-private${count.index + 1}-subnet" }
}

# EIP 할당
resource "aws_eip" "std17_nat_eip" {
    domain = "vpc"
    tags   = { Name = "std17-nat-eip" }
}

# NAT 게이트웨이
resource "aws_nat_gateway" "std17_nat" {
    allocation_id = aws_eip.std17_nat_eip.id
    subnet_id     = aws_subnet.std17_public_subnets[0].id
    depends_on    = [aws_internet_gateway.std17_vpc_igw]

    tags = { Name = "std17-nat" }
}

# 프라이빗 라우팅 테이블
resource "aws_route_table" "std17_vpc_private_rt" {
    vpc_id = aws_vpc.std17_vpc.id
    
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.std17_nat.id
    }

    tags = { Name = "std17-vpc-private-rt" }
}

resource "aws_route_table_association" "std17_vpc_private_rt_assoc" {
    count          = 2
    route_table_id = aws_route_table.std17_vpc_private_rt.id
    subnet_id      = aws_subnet.std17_private_subnets[count.index].id
}

# ==================================================================
# S3 Gateway VPC Endpoint (std17-ex-bucket 내부 전용선 접근용)
# ==================================================================
resource "aws_vpc_endpoint" "std17_s3_gateway" {
    vpc_id            = aws_vpc.std17_vpc.id
    service_name      = "com.amazonaws.${var.aws_region}.s3"
    vpc_endpoint_type = "Gateway"

    route_table_ids = [
        aws_route_table.std17_vpc_public_rt.id,
        aws_route_table.std17_vpc_private_rt.id,
    ]

    tags = { Name = "std17-s3-gateway-endpoint" }
}