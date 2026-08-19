resource "aws_ecs_cluster" "std17" {
    name = "std17-ecs-cluster"

    tags = { Name = "std17-ecs-cluster" }
}

# ------------------------------------------------------------
# General 노드 (nginx+fastapi) - AZ당 1대, 고정 개수
# ------------------------------------------------------------
resource "aws_launch_template" "std17_general_lt" {
    name_prefix   = "std17-general-"
    image_id      = var.ecs_ami_id
    instance_type = var.general_instance_type

    iam_instance_profile {
        name = var.ecs_instance_profile
    }

    vpc_security_group_ids = [var.ecs_general_sg_id]

    user_data = base64encode(<<-EOF
        #!/bin/bash
        echo "ECS_CLUSTER=${aws_ecs_cluster.std17.name}" >> /etc/ecs/ecs.config
        echo 'ECS_INSTANCE_ATTRIBUTES={"role":"general"}' >> /etc/ecs/ecs.config
    EOF
    )

    tag_specifications {
        resource_type = "instance"
        tags          = { Name = "std17-ecs-general" }
    }
}

resource "aws_autoscaling_group" "std17_general_asg" {
    name                = "std17-general-asg"
    min_size            = var.general_desired_count
    max_size            = var.general_desired_count
    desired_capacity    = var.general_desired_count
    vpc_zone_identifier = var.private_subnet_ids

    launch_template {
        id      = aws_launch_template.std17_general_lt.id
        version = "$Latest"
    }

    tag {
        key                 = "Name"
        value               = "std17-ecs-general"
        propagate_at_launch = true
    }
}

# ------------------------------------------------------------
# DB 노드 (mysql) - 1대 고정, ASG 아님
# ------------------------------------------------------------
resource "aws_instance" "std17_db_node" {
    ami                    = var.ecs_ami_id
    instance_type          = var.db_instance_type
    subnet_id              = var.private_subnet_ids[1]
    iam_instance_profile   = var.ecs_instance_profile
    vpc_security_group_ids = [var.ecs_db_sg_id]

    root_block_device {
        volume_size = 30
        volume_type = "gp3"
    }

    user_data = <<-EOF
        #!/bin/bash
        echo "ECS_CLUSTER=${aws_ecs_cluster.std17.name}" >> /etc/ecs/ecs.config
        echo 'ECS_INSTANCE_ATTRIBUTES={"role":"db"}' >> /etc/ecs/ecs.config
    EOF

    tags = { Name = "std17-ecs-db" }
}