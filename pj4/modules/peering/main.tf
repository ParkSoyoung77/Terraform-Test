resource "aws_vpc_peering_connection" "std17_peering" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = { Name = "std17-vpc-peering" }
}

# VPC1(웹) -> VPC2(DB) 라우트
resource "aws_route" "std17_vpc1_public_to_vpc2" {
  route_table_id            = var.vpc1_public_rt_id
  destination_cidr_block    = var.vpc2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.std17_peering.id
}

resource "aws_route" "std17_vpc1_private_to_vpc2" {
  route_table_id            = var.vpc1_private_rt_id
  destination_cidr_block    = var.vpc2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.std17_peering.id
}

# VPC2(DB) -> VPC1(웹) 라우트
resource "aws_route" "std17_vpc2_to_vpc1" {
  route_table_id            = var.vpc2_private_rt_id
  destination_cidr_block    = var.vpc1_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.std17_peering.id
}