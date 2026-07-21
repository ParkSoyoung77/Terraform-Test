# Transit Gateway
resource "aws_ec2_transit_gateway" "std17_tgw" {
    description                     = "std17-tgw"
    amazon_side_asn                 = 64512 # IANA가 "사설/내부용(Private Use)"으로 예약해둔 구간
    dns_support                     = "enable"
    vpn_ecmp_support                 = "enable"
    default_route_table_association = "enable"
    default_route_table_propagation = "enable"

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