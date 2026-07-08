locals {
  user_data_80 = <<-EOF
    #!/bin/bash
    curl -o /tmp/user-data.sh https://raw.githubusercontent.com/csjin21c/ex-aws/refs/heads/main/alb/ec2nginx80/user-data.sh
    chmod +x /tmp/user-data.sh
    /tmp/user-data.sh
  EOF

  user_data_8080 = <<-EOF
    #!/bin/bash
    curl -o /tmp/user-data.sh https://raw.githubusercontent.com/csjin21c/ex-aws/refs/heads/main/alb/ec2nginx8080/user-data.sh
    chmod +x /tmp/user-data.sh
    /tmp/user-data.sh
  EOF
}

resource "aws_instance" "std17_ec2" {
  count = 2

  ami           = "ami-03acbba64aef9bf5c"
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.std17_public_subnets[count.index].id
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

  # count.index == 0 -> 80포트용, 1 -> 8080포트용
  user_data = count.index == 0 ? local.user_data_80 : local.user_data_8080

  tags = { Name = "std17-${count.index}-ec2" }
}