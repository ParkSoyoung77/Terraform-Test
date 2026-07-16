# ==================================================================
# EC2 인스턴스
# ==================================================================

resource "aws_instance" "std17_public_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true
  source_dest_check           = false

  root_block_device {
    volume_size           = 10
    volume_type            = "gp3"
    delete_on_termination  = true
  }

  key_name = var.key_name

  vpc_security_group_ids = [
    var.security_group_id,
    var.nat_sg_id
  ]

  # 유저데이터
  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt update -y
    apt install -y nginx mysql-client iptables-persistent mariadb-client curl

    systemctl enable nginx
    systemctl start nginx

    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
    iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
    iptables -A FORWARD -i ens5 -o ens5 -j ACCEPT
    netfilter-persistent save
    systemctl enable netfilter-persistent
  EOF

  tags = { Name = "std17-public-ec2" }
}

resource "aws_instance" "std17_private_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.private_subnet_ids[0]
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

# # ==================================================================
# # AMI
# # ==================================================================

# resource "aws_ami_from_instance" "std17_ami" {
#     name                = "std17-ami"
#     source_instance_id  = aws_instance.std17_private_ec2.id

#     snapshot_without_reboot = false

#     depends_on = [time_sleep.wait_for_userdata]

#     tags = { Name = "std17-ami" }
# }

# # ==================================================================
# # Launch Template
# # ==================================================================

# resource "aws_launch_template" "std17_lt" {
#     image_id      = aws_ami_from_instance.std17_ami.id
#     name_prefix   = "std17-lt-"
#     instance_type = var.instance_type
#     key_name      = var.key_name

#     vpc_security_group_ids = [
#         var.security_group_id
#     ]

#     update_default_version = true
#     description             = "Launch template for ASG using custom AMI"

#     tag_specifications {
#         resource_type = "instance"
#         tags          = { Name = "std17-private-asg-instance" }
#     }
# }

# # ==================================================================
# # ALB
# # ==================================================================

# # 1. 대상그룹
# resource "aws_lb_target_group" "std17_80_tg" {
#     name     = "std17-80-tg"
#     port     = 80
#     protocol = "HTTP"
#     vpc_id   = var.vpc_id

#     slow_start           = 30
#     deregistration_delay = 30

#     health_check {
#         path                = "/"
#         protocol            = "HTTP"
#         interval            = 30
#         timeout             = 5
#         healthy_threshold   = 2
#         unhealthy_threshold = 3
#     }

#     tags = { Name = "std17-80-tg" }
# }

# # 2. 대상 그룹 인스턴스 등록
# # ASG가 target_group_arns로 자동 등록하므로 별도 attachment 불필요
# # resource "aws_lb_target_group_attachment" "std17_80_tg_attachment" {
# #     target_group_arn = aws_lb_target_group.std17_80_tg.arn
# #     target_id = aws_instance.std17_ec2_2.id
# #     port = 80
# # }

# # 3. ALB 생성
# resource "aws_lb" "std17_alb_80" {
#   name               = "std17-alb-80"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [var.security_group_id]
#   subnets            = var.public_subnet_ids

#   tags = { Name = "std17-alb-80" }
# }

# # 4. ALB 리스너 생성
# resource "aws_lb_listener" "std17_alb_80_listener" {
#   load_balancer_arn = aws_lb.std17_alb_80.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.std17_80_tg.arn
#   }
# }

# # ==================================================================
# # ASG
# # ==================================================================

# # 1. 개수에 대한 지정
# resource "aws_autoscaling_group" "std17_asg" {
#     name = "std17-asg"

#     desired_capacity = 3
#     min_size         = 1
#     max_size         = 5

#     launch_template {
#         id      = aws_launch_template.std17_lt.id
#         version = aws_launch_template.std17_lt.latest_version
#     }

#     vpc_zone_identifier = var.private_subnet_ids

#     lifecycle {
#         ignore_changes = [desired_capacity]
#     }

#     target_group_arns = [aws_lb_target_group.std17_80_tg.arn]

#     health_check_type         = "ELB"
#     health_check_grace_period = 300

#     instance_refresh {
#         strategy = "Rolling"
#         preferences {
#             min_healthy_percentage = 50
#             instance_warmup         = 300
#         }
#     }
# }

# # 2. 기준에 대한 지정
# resource "aws_autoscaling_policy" "std17_asg_policy" {
#     name                   = "std17-asg-policy"
#     autoscaling_group_name = aws_autoscaling_group.std17_asg.name

#     policy_type = "TargetTrackingScaling"

#     target_tracking_configuration {
#         predefined_metric_specification {
#             predefined_metric_type = "ASGAverageCPUUtilization"
#         }

#         target_value = 50.0
#     }
# }

# ==================================================================
# EC2 Instance Connect Endpoint
# ==================================================================

resource "aws_ec2_instance_connect_endpoint" "std17_eice" {
  subnet_id          = var.private_subnet_ids[0]
  security_group_ids = [var.security_group_id]

  tags = { Name = "std17-eice" }
}
