# resource "aws_key_pair" "std17_key" {
#     key_name = "std17-key"
#     public_key = file("~/.ssh/std17-key.pem")
# }

resource "aws_instance" "std17_ec2" {
    # ami는 우분투
    ami = "ami-03acbba64aef9bf5c"
    instance_type = "t3.micro"

    subnet_id = aws_subnet.std17_public_subnets[0].id
    associate_public_ip_address = true

    root_block_device {
        volume_size = 10
        volume_type = "gp3"
        delete_on_termination = true
    }

    key_name = "std17-key"

    vpc_security_group_ids = [
        aws_security_group.std17_ssh_sg.id,
        aws_security_group.std17_http_sg.id
    ]


    # 아파치 설치
    user_data = <<-EOF
        #!/bin/bash
        apt update -y
        apt install -y apache2

        systemctl enable apache2
        systemctl start apache2
    EOF

    tags = { Name = "std17-ec2" }
}

