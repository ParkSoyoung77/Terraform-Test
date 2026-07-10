resource "aws_instance" "std17_public_ec2" {

  ami           = "ami-0fb110df4c5094d21"
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.std17_public_subnets[0].id
  associate_public_ip_address = true

  root_block_device {
    volume_size            = 10
    volume_type            = "gp3"
    delete_on_termination  = true
  }

  key_name = "std17-key"

  vpc_security_group_ids = [
    aws_security_group.std17_test_sg.id
  ]

  # 유저데이터
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx mysql-client

    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = { Name = "std17-public-ec2" }
}

resource "aws_instance" "std17_private_ec2" {

  ami           = "ami-0fb110df4c5094d21"
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.std17_private_subnets[0].id
  associate_public_ip_address = false

  root_block_device {
    volume_size            = 10
    volume_type            = "gp3"
    delete_on_termination  = true
  }

  key_name = "std17-key"

  vpc_security_group_ids = [
    aws_security_group.std17_test_sg.id
  ]

  # 유저데이터
  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y nginx mysql-client

cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>std17 Static Website</title>
<style>
body {
    margin: 0;
    font-family: -apple-system, "Malgun Gothic", sans-serif;
    background: linear-gradient(135deg, #1e3c72, #2a5298);
    color: #fff;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
}
.container {
    text-align: center;
    padding: 40px;
    background: rgba(255, 255, 255, 0.08);
    border-radius: 16px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.3);
}
h1 {
    font-size: 2.2rem;
    margin-bottom: 10px;
}
p {
    font-size: 1.1rem;
    opacity: 0.85;
    margin: 6px 0;
}
.badge {
    display: inline-block;
    margin-top: 20px;
    padding: 6px 16px;
    background: rgba(255,255,255,0.15);
    border-radius: 20px;
    font-size: 0.85rem;
    letter-spacing: 0.5px;
}
</style>
</head>
<body>
    <div class="container">
        <h1>std17-s3-bucket</h1>
        <p>AWS 정적 웹사이트 호스팅 테스트 페이지</p>
        <p>Terraform으로 배포함</p>
        <div class="badge">Owner: std17 &nbsp;|&nbsp; Class: bipa17</div>
    </div>
</body>
</html>
HTML

systemctl enable nginx
systemctl start nginx
EOF

  user_data_replace_on_change = true

  tags = { Name = "std17-private-ec2" }
}

resource "time_sleep" "wait_for_userdata" {
  create_duration = "200s"

  triggers = {
    instance_id = aws_instance.std17_private_ec2.id
  }
}