# ==================================================================
# ENI (세컨더리 프라이빗 IP 부여용)
# ==================================================================
resource "aws_network_interface" "std17_public_eni" {

  count = 3

  subnet_id       = var.public_subnet_ids[count.index]
  security_groups = [var.security_group_id]

  private_ip_list_enabled = true
  private_ip_list          = [var.fixed_private_ips[count.index]]

  tags = { Name = "std17-public-eni-${count.index + 1}" }
}

# ==================================================================
# EC2
# ==================================================================
resource "aws_instance" "std17_public_ec2" {

  count = 3

  ami           = var.instance_ami
  instance_type = var.instance_type

  iam_instance_profile = var.iam_instance_profile

  primary_network_interface {
    network_interface_id = aws_network_interface.std17_public_eni[count.index].id
  }

  root_block_device {
    volume_size          = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  key_name = var.key_name

  user_data                   = file("${path.module}/scripts/user_data.sh")
  user_data_replace_on_change = true

  tags = { Name = "std17-public-ec2-${count.index + 1}" }
}

resource "aws_eip" "std17_public_ec2_eip" {

  count = 3

  domain             = "vpc"
  network_interface  = aws_network_interface.std17_public_eni[count.index].id

  depends_on = [aws_instance.std17_public_ec2]

  tags = { Name = "std17-public-ec2-eip-${count.index + 1}" }
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