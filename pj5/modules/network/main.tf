resource "aws_vpc" "std17_vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = { Name = "std17-vpc" }
}

resource "aws_internet_gateway" "std17_igw" {
    vpc_id = aws_vpc.std17_vpc.id
    tags   = { Name = "std17-igw" }
}

# public subnets (AZ당 1개, ALB용)
resource "aws_subnet" "std17_public_subnets" {
    count                   = 2
    vpc_id                  = aws_vpc.std17_vpc.id
    cidr_block              = "10.0.${count.index + 1}.0/24"
    availability_zone       = var.azs[count.index]
    map_public_ip_on_launch = true

    tags = { Name = "std17-public${count.index + 1}-subnet" }
}

# private subnets (AZ당 1개, ECS 노드용)
resource "aws_subnet" "std17_private_subnets" {
    count             = 2
    vpc_id            = aws_vpc.std17_vpc.id
    cidr_block        = "10.0.${count.index + 11}.0/24"
    availability_zone = var.azs[count.index]

    tags = { Name = "std17-private${count.index + 1}-subnet" }
}

resource "aws_route_table" "std17_public_rt" {
    vpc_id = aws_vpc.std17_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.std17_igw.id
    }

    tags = { Name = "std17-public-rt" }
}

resource "aws_route_table_association" "std17_public_rt_assoc" {
    count          = 2
    route_table_id = aws_route_table.std17_public_rt.id
    subnet_id      = aws_subnet.std17_public_subnets[count.index].id
}

# NAT: SSM 세션, OS 패치용 (ECR pull은 Interface Endpoint로 감)
resource "aws_eip" "std17_nat_eip" {
    domain = "vpc"
    tags   = { Name = "std17-nat-eip" }
}

resource "aws_nat_gateway" "std17_nat" {
    allocation_id = aws_eip.std17_nat_eip.id
    subnet_id     = aws_subnet.std17_public_subnets[0].id
    depends_on    = [aws_internet_gateway.std17_igw]

    tags = { Name = "std17-nat" }
}

resource "aws_route_table" "std17_private_rt" {
    vpc_id = aws_vpc.std17_vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.std17_nat.id
    }

    tags = { Name = "std17-private-rt" }
}

resource "aws_route_table_association" "std17_private_rt_assoc" {
    count          = 2
    route_table_id = aws_route_table.std17_private_rt.id
    subnet_id      = aws_subnet.std17_private_subnets[count.index].id
}

# S3 Gateway 엔드포인트 (ECR 이미지 레이어 저장소, 무료)
resource "aws_vpc_endpoint" "std17_s3_gw" {
    vpc_id            = aws_vpc.std17_vpc.id
    service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids   = [aws_route_table.std17_private_rt.id]

    tags = { Name = "std17-s3-gw-endpoint" }
}

data "aws_region" "current" {}