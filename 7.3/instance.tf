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


    # nginx 설치
    user_data = <<-EOF
        #!/bin/bash

        # 운영체제 확인 (ubuntu 또는 amzn)
        OS_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
        echo "Detected OS: $OS_ID"

        if [ "$OS_ID" == "ubuntu" ]; then
            PKG_MANAGER="apt"
            WEB_ROOT="/var/www/html"
            $PKG_MANAGER update -y
        elif [ "$OS_ID" == "amzn" ]; then
            PKG_MANAGER="dnf"
            WEB_ROOT="/usr/share/nginx/html"
            $PKG_MANAGER update -y
        else
            echo "지원되지 않는 운영체제입니다."
            exit 1
        fi

        $PKG_MANAGER install -y nginx

        curl -o $WEB_ROOT/index.html https://raw.githubusercontent.com/csjin21c/aws/refs/heads/main/ALB/index.html

        if [ -f "$WEB_ROOT/index.html" ]; then
            echo "index.html 다운로드 성공: $WEB_ROOT/index.html"
        else
            echo "index.html 다운로드 실패"
            exit 1
        fi

        sed -i "s/{{HOSTNAME}}/$(hostname)/g" $WEB_ROOT/index.html

        cat <<CHARSET > /etc/nginx/conf.d/charset.conf
charset utf-8;
CHARSET

        nginx -t
        systemctl enable nginx
        systemctl start nginx
    EOF

    tags = { Name = "std17-ec2" }
}

