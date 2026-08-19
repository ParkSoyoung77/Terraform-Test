# ---------------------------------------------------------
# ECS 컨테이너 인스턴스 역할 (EC2에 붙는 역할)
# - ECS 클러스터 등록 + ECR pull
# - SSM Session Manager 접속
# ---------------------------------------------------------
resource "aws_iam_role" "std17_ecs_instance_role" {
    name = "std17-ecs-instance-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })

    tags = { Name = "std17-ecs-instance-role" }
}

resource "aws_iam_role_policy_attachment" "std17_ecs_instance_attach" {
    role       = aws_iam_role.std17_ecs_instance_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "std17_ssm_attach" {
    role       = aws_iam_role.std17_ecs_instance_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "std17_ecs_instance_profile" {
    name = "std17-ecs-instance-profile"
    role = aws_iam_role.std17_ecs_instance_role.name
}

# ---------------------------------------------------------
# ECS Task Execution 역할 (Task가 시작될 때 AWS가 대신 쓰는 역할)
# Secrets Manager 접근 권한은 ecs 모듈에서 인라인 정책으로 추가
# ---------------------------------------------------------
resource "aws_iam_role" "std17_task_execution_role" {
    name = "std17-task-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect    = "Allow"
            Principal = { Service = "ecs-tasks.amazonaws.com" }
            Action    = "sts:AssumeRole"
        }]
    })

    tags = { Name = "std17-task-execution-role" }
}

resource "aws_iam_role_policy_attachment" "std17_task_execution_attach" {
    role       = aws_iam_role.std17_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}