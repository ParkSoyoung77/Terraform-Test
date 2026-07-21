# Transit Gateway
resource "aws_ec2_transit_gateway" "std17_tgw" {
    description                     = "std17-tgw"
    amazon_side_asn                 = 64512 # IANA가 "사설/내부용(Private Use)"으로 예약해둔 구간
    dns_support                        = "enable"
    vpn_ecmp_support                   = "enable"
    default_route_table_association    = "enable"
    default_route_table_propagation    = "enable"
    security_group_referencing_support = "enable"
    encryption_support                 = "enable"

    tags = {
        Name = "std17-tgw"
    }
}

# VPC1 (network) 연결
resource "aws_ec2_transit_gateway_vpc_attachment" "std17_tga_vpc1" {
    transit_gateway_id = aws_ec2_transit_gateway.std17_tgw.id
    vpc_id             = var.vpc1_id
    subnet_ids         = var.vpc1_subnet_ids

    dns_support                        = "enable"
    security_group_referencing_support = "enable"

    tags = {
        Name = "std17-tga-vpc1"
    }
}

# VPC2 (network2) 연결
resource "aws_ec2_transit_gateway_vpc_attachment" "std17_tga_vpc2" {
    transit_gateway_id = aws_ec2_transit_gateway.std17_tgw.id
    vpc_id             = var.vpc2_id
    subnet_ids         = var.vpc2_subnet_ids

    dns_support                        = "enable"
    security_group_referencing_support = "enable"

    tags = {
        Name = "std17-tga-vpc2"
    }
}

# ---------------- network(vpc1) -> network2 CIDR ----------------
resource "aws_route" "vpc1_private_to_vpc2" {
    route_table_id         = var.vpc1_route_table_id
    destination_cidr_block = var.vpc2_cidr
    transit_gateway_id     = aws_ec2_transit_gateway.std17_tgw.id

    depends_on = [
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc1,
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc2
    ]
}

resource "aws_route" "vpc1_public_to_vpc2" {
    route_table_id         = var.vpc1_public_route_table_id
    destination_cidr_block = var.vpc2_cidr
    transit_gateway_id     = aws_ec2_transit_gateway.std17_tgw.id

    depends_on = [
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc1,
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc2
    ]
}

resource "aws_route" "vpc1_default_to_vpc2" {
    route_table_id         = var.vpc1_default_route_table_id
    destination_cidr_block = var.vpc2_cidr
    transit_gateway_id     = aws_ec2_transit_gateway.std17_tgw.id

    depends_on = [
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc1,
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc2
    ]
}

# ---------------- network2(vpc2) -> network CIDR ----------------
resource "aws_route" "vpc2_private_to_vpc1" {
    route_table_id         = var.vpc2_route_table_id
    destination_cidr_block = var.vpc1_cidr
    transit_gateway_id     = aws_ec2_transit_gateway.std17_tgw.id

    depends_on = [
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc1,
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc2
    ]
}

resource "aws_route" "vpc2_public_to_vpc1" {
    route_table_id         = var.vpc2_public_route_table_id
    destination_cidr_block = var.vpc1_cidr
    transit_gateway_id     = aws_ec2_transit_gateway.std17_tgw.id

    depends_on = [
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc1,
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc2
    ]
}

resource "aws_route" "vpc2_default_to_vpc1" {
    route_table_id         = var.vpc2_default_route_table_id
    destination_cidr_block = var.vpc1_cidr
    transit_gateway_id     = aws_ec2_transit_gateway.std17_tgw.id

    depends_on = [
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc1,
        aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc2
    ]
}