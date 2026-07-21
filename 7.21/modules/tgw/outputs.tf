output "tgw_id" {
    value = aws_ec2_transit_gateway.std17_tgw.id
}

output "tgw_attach_vpc1_id" {
    value = aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc1.id
}

output "tgw_attach_vpc2_id" {
    value = aws_ec2_transit_gateway_vpc_attachment.std17_tga_vpc2.id
}