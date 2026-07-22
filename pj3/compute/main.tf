# ==================================================================
# EC2 인스턴스 (Golden AMI 원본)
# ==================================================================

resource "aws_instance" "std17_private_ec2" {

  ami           = var.instance_ami
  instance_type = var.instance_type

  subnet_id                   = var.private_subnet_ids[0]
  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    volume_size           = 10
    volume_type            = "gp3"
    delete_on_termination  = true
  }

  key_name = var.key_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  # 유저데이터: 1번 html(index.html)만 nginx로 서빙
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
aws s3 sync s3://std17-ex-bucket/ /var/www/html/
systemctl restart nginx
EOF

  user_data_replace_on_change = true

  tags = { Name = "std17-private-ec2" }
}

# user_data(nginx 설치 + S3 sync)가 끝날 때까지 대기 후 AMI 생성
resource "time_sleep" "wait_for_userdata" {
  create_duration = "200s"

  triggers = {
    instance_id = aws_instance.std17_private_ec2.id
  }
}

# ==================================================================
# 엔드포인트
# ==================================================================

# S3 Gateway VPC 엔드포인트
resource "aws_vpc_endpoint" "std17_gw_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-west-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.route_table_ids

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Statement1"
        Effect    = "Allow"
        Principal = "*"
        Action    = "*"
        Resource  = "*"
      }
    ]
  })

  tags = {
    Name = "std17-gw-endpoint"
  }
}

# ==================================================================
# AMI / Launch Template (Golden AMI 방식)
# ==================================================================
resource "aws_ami_from_instance" "std17_ami" {
    name                = "std17-ami"
    source_instance_id  = aws_instance.std17_private_ec2.id

    snapshot_without_reboot = false

    depends_on = [time_sleep.wait_for_userdata]

    tags = { Name = "std17-ami" }
}

resource "aws_launch_template" "std17_lt" {
    image_id      = aws_ami_from_instance.std17_ami.id
    name_prefix   = "std17-lt-"
    instance_type = var.instance_type
    key_name      = var.key_name

    vpc_security_group_ids = [
        var.security_group_id
    ]

    update_default_version = true
    description             = "Launch template for ASG using custom AMI"

    tag_specifications {
        resource_type = "instance"
        tags          = { Name = "std17-private-asg-instance" }
    }
}

# ==================================================================
# ASG (nginx, min1/desired2/max3, 프라이빗 서브넷)
# 타겟그룹은 alb 모듈에서 생성한 것을 var로 전달받아 등록
# ==================================================================
resource "aws_autoscaling_group" "std17_asg" {
    name = "std17-asg"

    desired_capacity = 2
    min_size         = 1
    max_size         = 3

    launch_template {
        id      = aws_launch_template.std17_lt.id
        version = aws_launch_template.std17_lt.latest_version
    }

    vpc_zone_identifier = var.private_subnet_ids

    lifecycle {
        ignore_changes = [desired_capacity]
    }

    target_group_arns = [var.target_group_arn]

    health_check_type         = "ELB"
    health_check_grace_period = 300

    instance_refresh {
        strategy = "Rolling"
        preferences {
            min_healthy_percentage = 50
            instance_warmup         = 300
        }
    }
}

resource "aws_autoscaling_policy" "std17_asg_policy" {
    name                   = "std17-asg-policy"
    autoscaling_group_name = aws_autoscaling_group.std17_asg.name

    policy_type = "TargetTrackingScaling"

    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }

        target_value = 50.0
    }
}

# ==================================================================
# EC2 Instance Connect Endpoint
# ==================================================================

resource "aws_ec2_instance_connect_endpoint" "std17_eice" {
  subnet_id          = var.private_subnet_ids[0]
  security_group_ids = [var.security_group_id]

  tags = { Name = "std17-eice" }
}