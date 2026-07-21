# ==================================================================
# EC2 인스턴스
# ==================================================================

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
<title>CloudTrip - AWS 클라우드 아키텍처</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: 'Segoe UI', 'Malgun Gothic', sans-serif;
    background: linear-gradient(135deg, #232f3e 0%, #131a22 100%);
    color: #ffffff;
    min-height: 100vh;
  }
  header {
    padding: 24px 40px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgba(255,255,255,0.1);
  }
  .logo { font-size: 22px; font-weight: 700; color: #ff9900; }
  nav a {
    color: #ffffff;
    text-decoration: none;
    margin-left: 28px;
    font-size: 15px;
    transition: color 0.2s;
  }
  nav a:hover { color: #ff9900; }
  .hero {
    text-align: center;
    padding: 100px 20px 80px;
  }
  .hero h1 {
    font-size: 44px;
    margin-bottom: 16px;
  }
  .hero span { color: #ff9900; }
  .hero p {
    font-size: 18px;
    color: #c9d1d9;
    max-width: 600px;
    margin: 0 auto 32px;
  }
  .btn {
    display: inline-block;
    background: #ff9900;
    color: #131a22;
    padding: 14px 32px;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 700;
    margin: 0 8px;
    transition: transform 0.2s;
  }
  .btn:hover { transform: translateY(-2px); }
  .btn.outline {
    background: transparent;
    border: 2px solid #ff9900;
    color: #ff9900;
  }
  .cards {
    display: flex;
    gap: 24px;
    justify-content: center;
    flex-wrap: wrap;
    padding: 0 40px 80px;
  }
  .card {
    background: rgba(255,255,255,0.05);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 12px;
    padding: 28px;
    width: 260px;
    text-align: center;
  }
  .card .icon { font-size: 32px; margin-bottom: 12px; }
  .card h3 { color: #ff9900; margin-bottom: 8px; font-size: 17px; }
  .card p { color: #9fa6b2; font-size: 14px; line-height: 1.5; }
  footer {
    text-align: center;
    padding: 24px;
    color: #6b7280;
    font-size: 13px;
    border-top: 1px solid rgba(255,255,255,0.1);
  }
</style>
</head>
<body>
  <header>
    <div class="logo">☁️ CloudTrip</div>
    <nav>
      <a href="index.html">홈</a>
      <a href="about.html">소개</a>
      <a href="services.html">아키텍처</a>
    </nav>
  </header>

  <section class="hero">
    <h1>AWS 기반 <span>하이브리드 클라우드</span><br>아키텍처</h1>
    <p>VPC, ALB, ASG, RDS, CloudFront로 구성된 확장 가능한 글로벌 OTA 플랫폼 인프라</p>
    <a class="btn" href="services.html">아키텍처 보기</a>
    <a class="btn outline" href="about.html">프로젝트 소개</a>
  </section>

  <section class="cards">
    <div class="card">
      <div class="icon">🖥️</div>
      <h3>Auto Scaling</h3>
      <p>ALB 뒤에서 최소 1대, 유지 2대, 최대 3대로 동작하는 nginx 인스턴스</p>
    </div>
    <div class="card">
      <div class="icon">🗄️</div>
      <h3>RDS MySQL</h3>
      <p>격리된 데이터베이스 서브넷에서 Secrets Manager로 보호되는 studydb</p>
    </div>
    <div class="card">
      <div class="icon">🚀</div>
      <h3>Lambda + API GW</h3>
      <p>서버리스 함수로 DB 연결 상태를 실시간으로 확인</p>
    </div>
  </section>

  <footer>
    KDT MSP 6기 · CloudTrip Project · std17
  </footer>
</body>
</html>
HTML

systemctl enable nginx
systemctl start nginx
EOF

  user_data_replace_on_change = true

  tags = { Name = "std17-private-ec2" }
}

# resource "time_sleep" "wait_for_userdata" {
#   create_duration = "200s"

#   triggers = {
#     instance_id = aws_instance.std17_private_ec2.id
#   }
# }

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

#     desired_capacity = 2
#     min_size         = 1
#     max_size         = 3

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
