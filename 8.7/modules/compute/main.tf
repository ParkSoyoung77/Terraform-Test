# ==================================================================
# ENI (세컨더리 프라이빗 IP 부여용)
# ==================================================================
resource "aws_network_interface" "std17_public_eni" {
  subnet_id       = var.public_subnet_ids[0]
  security_groups = [var.security_group_id]

  private_ips = [
    var.primary_private_ip,
    var.secondary_private_ip
  ]

  tags = { Name = "std17-public-eni" }
}

# ==================================================================
# EC2
# ==================================================================
resource "aws_instance" "std17_public_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  iam_instance_profile = var.iam_instance_profile

  network_interface {
    network_interface_id = aws_network_interface.std17_public_eni.id
    device_index          = 0
  }

  root_block_device {
    volume_size          = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  key_name = var.key_name

  user_data                   = file("${path.module}/scripts/user_data.sh")
  user_data_replace_on_change = true

  tags = { Name = "std17-public-ec2" }
}

resource "aws_eip" "std17_public_ec2_eip" {
  domain                    = "vpc"
  network_interface          = aws_network_interface.std17_public_eni.id
  associate_with_private_ip = var.primary_private_ip

  tags = { Name = "std17-public-ec2-eip" }
}

# ==================================================================
# 엔드포인트
# ==================================================================

# S3 Gateway VPC 엔드포인트
resource "aws_vpc_endpoint" "std17_gw_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-northeast-3.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.route_table_ids

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Statement1"
        Effect    = "Allow"
        Principal = "*"
        Action    = "*"
        Resource  = "*"
      }
    ]
  })

  tags = {
    Name = "std17-gw-endpoint"
  }
}