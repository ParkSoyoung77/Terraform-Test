# 1. 대상그룹
resource "aws_lb_target_group" "std17_main_tg" {
    name= "std17-main-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.std17_vpc.id

    slow_start = 30
    deregistration_delay = 30

    health_check {
        path = "/"
        protocol = "HTTP"
        interval= 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 3
    }
}

# 2. 대상 그룹 인스턴스 등록
# resource "aws_lb_target_group_attachment" "std17_main_tg_attachment" {
#     target_group_arn = aws_lb_target_group.std17_main_tg.arn
#     target_id = aws_instance.std17_ec2.id
#     port = 80
# }

# 3. ALB 생성
resource "aws_lb" "std17_alb" {
    name = "std17-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.std17_http_sg.id]
    subnets = aws_subnet.std17_public_subnets[*].id

    tags={ Name = "std17-alb" }
}

# 4. ALB 리스너 생성
resource "aws_lb_listener" "std17_alb_http_listener"{
    load_balancer_arn = aws_lb.std17_alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.std17_main_tg.arn
    }
}