# ==================================================================
# EC2 인스턴스
# ==================================================================

resource "aws_instance" "std17_public_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true

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
apt install -y nginx mysql-client

systemctl enable nginx
systemctl start nginx
EOF

  user_data_replace_on_change = true

  tags = { Name = "std17-public-ec2" }
}

resource "aws_instance" "std17_amazon_ec2" {

  ami           = var.amazon_ami
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true

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
dnf update -y
dnf install -y nginx mysql-client

systemctl enable nginx
systemctl start nginx
EOF

  user_data_replace_on_change = true

  tags = { Name = "std17-amazon-ec2" }
}