# ==================================================================
# EC2 인스턴스 (커스텀 AMI 생성용 시드 인스턴스)
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

resource "time_sleep" "wait_for_userdata" {
  create_duration = "200s"

  triggers = {
    instance_id = aws_instance.std17_private_ec2.id
  }
}

# ==================================================================
# AMI / Launch Template
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

    iam_instance_profile {           
        name = var.iam_instance_profile
    }

    update_default_version = true
    description             = "Launch template for ASG using custom AMI"

    tag_specifications {
        resource_type = "instance"
        tags          = { Name = "std17-private-asg-instance" }
    }
}

# ==================================================================
# ASG (nginx 2대) - compute 모듈의 공인 ALB 대상그룹에 직접 등록
# ==================================================================
resource "aws_autoscaling_group" "std17_asg" {
    name = "std17-asg"

    desired_capacity = 1
    min_size         = 1
    max_size         = 2

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
# EC2 Instance Connect Endpoint (private 인스턴스 SSH 접속용)
# ==================================================================
resource "aws_ec2_instance_connect_endpoint" "std17_eice" {
  subnet_id          = var.private_subnet_ids[0]
  security_group_ids = [var.security_group_id]

  tags = { Name = "std17-eice" }
}