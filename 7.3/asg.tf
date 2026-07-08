# 1. 개수에 대한 지정
resource "aws_autoscaling_group" "std17_asg" {
    name = "std17-asg"

    desired_capacity = 2
    min_size = 1
    max_size = 5

    launch_template {
        id = aws_launch_template.std17_lt.id
        version = "$Latest"
    }

    vpc_zone_identifier = aws_subnet.std17_public_subnets[*].id


    lifecycle {
        ignore_changes = [desired_capacity]
    }

    target_group_arns = [aws_lb_target_group.std17_main_tg.arn]

    health_check_type = "ELB"
    health_check_grace_period = 300

    instance_refresh {
        strategy = "Rolling"
        preferences {
            min_healthy_percentage = 50
            instance_warmup = 300
        }
    }
}

# 2. 기준에 대한 지정
resource "aws_autoscaling_policy" "std17_asg_policy"{
    name = "std17-asg-policy"
    autoscaling_group_name = aws_autoscaling_group.std17_asg.name

    policy_type = "TargetTrackingScaling"

    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }

        target_value = 50.0
    }
}