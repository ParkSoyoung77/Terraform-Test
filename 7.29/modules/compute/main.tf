resource "aws_instance" "std17_public_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true

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

tee /etc/nginx/conf.d/charset.conf > /dev/null << 'CONF'
charset utf-8;
CONF

tee /var/www/html/index.html > /dev/null << 'HTML'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>std17 Public EC2</title>
</head>
<body>
    <h1>std17-public-ec2</h1>
    <p>오사카 리전(ap-northeast-3) 배포 완료</p>
</body>
</html>
HTML

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