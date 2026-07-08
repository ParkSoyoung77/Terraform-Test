# vpc
resource "aws_vpc" "std17_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "std17-vpc"
    }
}

# public subnets
resource "aws_subnet" "std17_public_subnets" {
    count = 2
    vpc_id = aws_vpc.std17_vpc.id
    cidr_block = "10.0.${count.index + 1}.0/24"
    availability_zone = ["ap-southeast-1a", "ap-southeast-1b"][count.index]

    map_public_ip_on_launch = true
    enable_resource_name_dns_a_record_on_launch = true

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
resource "aws_route_table" "std17_vpc_public_rt"{
    vpc_id = aws_vpc.std17_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.std17_vpc_igw.id
    }

    tags = {
        Name = "std17-vpc-public-rt"
    }
}

resource "aws_route_table_association" "std17_vpc_public_rt_assoc"{
    count = 2
    route_table_id = aws_route_table.std17_vpc_public_rt.id
    subnet_id = aws_subnet.std17_public_subnets[count.index].id
}