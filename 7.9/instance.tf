resource "aws_instance" "std17_ec2" {

  ami           = "ami-0e5497a77ef21b5ac"
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

    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = { Name = "std17-ec2" }
}

resource "aws_instance" "std17_ec2_2" {

  ami           = "ami-0e5497a77ef21b5ac"
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

  tags = { Name = "std17-ec2-2" }
}