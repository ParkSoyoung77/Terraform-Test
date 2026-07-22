# ==================================================================
# EC2 인스턴스
# ==================================================================

resource "aws_instance" "std17_public_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true
  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    volume_size           = 10
    volume_type            = "gp3"
    delete_on_termination  = true
  }

  key_name = var.key_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  # 유저데이터
  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y nginx mysql-client unzip curl

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

resource "aws_instance" "std17_private_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.private_subnet_ids[0]
  associate_public_ip_address = false
  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    volume_size           = 10
    volume_type            = "gp3"
    delete_on_termination  = true
  }

  key_name = var.key_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  # 유저데이터
  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y nginx mysql-client unzip curl

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

  tags = { Name = "std17-private-ec2" }
}

# resource "aws_instance" "std17_amazon_ec2" {

#   ami           = var.amazon_ami
#   instance_type = var.instance_type

#   subnet_id                   = var.public_subnet_ids[0]
#   associate_public_ip_address = true

#   root_block_device {
#     volume_size           = 10
#     volume_type            = "gp3"
#     delete_on_termination  = true
#   }

#   key_name = var.key_name

#   vpc_security_group_ids = [
#     var.security_group_id
#   ]

#   # 유저데이터
#   user_data = <<-EOF
# #!/bin/bash
# dnf update -y
# dnf install -y nginx mariadb105

# systemctl enable nginx
# systemctl start nginx
# EOF

#   user_data_replace_on_change = true

#   tags = { Name = "std17-amazon-ec2" }
# }

# ==================================================================
# 엔드포인트
# ==================================================================

# # S3 Gateway VPC 엔드포인트
# resource "aws_vpc_endpoint" "std17_gw_endpoint" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.us-west-1.s3"
#   vpc_endpoint_type = "Gateway"

#   route_table_ids = var.route_table_ids

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "Statement1"
#         Effect    = "Allow"
#         Principal = "*"
#         Action    = "*"
#         Resource  = "*"
#       }
#     ]
#   })

#   tags = {
#     Name = "std17-gw-endpoint"
#   }
# }

# Interface VPC 엔드포인트
resource "aws_vpc_endpoint" "std17_interface_endpoint" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.us-west-1.s3"
  vpc_endpoint_type   = "Interface"
  ip_address_type     = "ipv4"

  subnet_ids          = var.public_subnet_ids
  security_group_ids  = [var.security_group_id]

  private_dns_enabled = true

  tags = {
    Name = "std17-interface-endpoint"
  }
}

# EC2 Instance Connect Endpoint
resource "aws_ec2_instance_connect_endpoint" "std17_eice" {
  subnet_id          = var.public_subnet_ids[0]
  security_group_ids = [var.security_group_id]

  tags = { Name = "std17-eice" }
}