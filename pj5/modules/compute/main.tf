resource "aws_instance" "std17_public_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    volume_size           = 8
    volume_type            = "gp3"
    delete_on_termination  = true
  }

  key_name = var.key_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  user_data = file("${path.module}/scripts/user_data.sh")
  user_data_replace_on_change = true

  tags = { Name = "std17-public-ec2" }
}

# ==================================================================
# 추가 EBS 볼륨 (8GB)
# ==================================================================
resource "aws_ebs_volume" "std17_extra_volume" {
  availability_zone = aws_instance.std17_public_ec2.availability_zone
  size               = 10
  type               = "gp3"

  tags = { Name = "std17-public-ec2-extra" }
}

resource "aws_volume_attachment" "std17_extra_volume_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.std17_extra_volume.id
  instance_id = aws_instance.std17_public_ec2.id
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