# ==================================================================
# EC2 인스턴스 (Golden AMI 원본)
# ==================================================================

resource "aws_instance" "std17_public_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = false

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

systemctl restart nginx
EOF

  user_data_replace_on_change = true

  tags = { Name = "std17-public-ec2" }
}