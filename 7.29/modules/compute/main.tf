resource "aws_instance" "std17_public_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile

  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type            = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  root_block_device {
    volume_size           = 10
    volume_type            = "gp3"
    delete_on_termination  = true
  }

  key_name = var.key_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y nginx unzip curl

systemctl enable nginx
systemctl start nginx

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip
aws s3 sync s3://std17-ex-bucket/ /var/www/html/
systemctl restart nginx
EOF

  user_data_replace_on_change = true

  tags = { Name = "std17-public-ec2" }
}

# ==================================================================
# 추가 EBS 볼륨 (8GB)
# ==================================================================
resource "aws_ebs_volume" "std17_extra_volume" {
  availability_zone = aws_instance.std17_public_ec2.availability_zone
  size               = 8
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
  service_name      = "com.amazonaws.us-west-1.s3"
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