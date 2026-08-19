locals {
    ecr_registry = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    secret_arn   = var.mysql_credentials_secret_arn
}

# 시크릿 하나만 참조하므로 IAM 정책도 단순함
resource "aws_iam_role_policy" "std17_task_exec_secrets" {
    name = "std17-task-exec-secrets-policy"
    role = var.execution_role_name

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect   = "Allow"
            Action   = ["secretsmanager:GetSecretValue"]
            Resource = [local.secret_arn]
        }]
    })
}

# ------------------------------------------------------------
# Cloud Map - DB 노드 사설 DNS (mysql.std17.local)
# ------------------------------------------------------------
resource "aws_service_discovery_private_dns_namespace" "std17" {
    name = "std17.local"
    vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "mysql" {
    name = "mysql"

    dns_config {
        namespace_id = aws_service_discovery_private_dns_namespace.std17.id

        dns_records {
            ttl  = 10
            type = "A"
        }

        routing_policy = "MULTIVALUE"
    }
}

# ------------------------------------------------------------
# Web Task (nginx + fastapi sidecar)
# ------------------------------------------------------------
resource "aws_ecs_task_definition" "std17_web" {
    family                   = "std17-web-task"
    requires_compatibilities = ["EC2"]
    network_mode             = "bridge"
    execution_role_arn       = var.execution_role_arn

    container_definitions = jsonencode([
        {
            name      = "nginx"
            image     = "${local.ecr_registry}/std17-nginx:latest"
            essential = true
            portMappings = [
                { containerPort = 80, hostPort = 0, protocol = "tcp" }
            ]
        },
        {
            name      = "fastapi"
            image     = "${local.ecr_registry}/std17-fastapi:latest"
            essential = true
            secrets = [
                { name = "DB_HOST",     valueFrom = "${local.secret_arn}:host::" },
                { name = "DB_PORT",     valueFrom = "${local.secret_arn}:port::" },
                { name = "DB_USER",     valueFrom = "${local.secret_arn}:app_username::" },
                { name = "DB_PASSWORD", valueFrom = "${local.secret_arn}:app_password::" },
                { name = "DB_NAME",     valueFrom = "${local.secret_arn}:database::" }
            ]
        }
    ])
}

resource "aws_ecs_service" "std17_web" {
    name            = "std17-web-service"
    cluster         = var.cluster_name
    task_definition = aws_ecs_task_definition.std17_web.arn
    desired_count   = var.general_desired_count
    launch_type     = "EC2"

    load_balancer {
        target_group_arn = var.target_group_arn
        container_name   = "nginx"
        container_port   = 80
    }

    placement_constraints {
        type       = "memberOf"
        expression = "attribute:role == general"
    }

    ordered_placement_strategy {
        type  = "spread"
        field = "attribute:ecs.availability-zone"
    }
}

# ------------------------------------------------------------
# DB Task (mysql)
# ------------------------------------------------------------
resource "aws_ecs_task_definition" "std17_db" {
    family                   = "std17-db-task"
    requires_compatibilities = ["EC2"]
    network_mode             = "bridge"
    execution_role_arn       = var.execution_role_arn

    container_definitions = jsonencode([
        {
            name      = "mysql"
            image     = "${local.ecr_registry}/std17-mysql:latest"
            essential = true
            portMappings = [
                { containerPort = 3306, hostPort = 3306, protocol = "tcp" }
            ]
            secrets = [
                { name = "MYSQL_ROOT_PASSWORD", valueFrom = "${local.secret_arn}:root_password::" },
                { name = "MYSQL_DATABASE",      valueFrom = "${local.secret_arn}:database::" },
                { name = "MYSQL_USER",          valueFrom = "${local.secret_arn}:app_username::" },
                { name = "MYSQL_PASSWORD",      valueFrom = "${local.secret_arn}:app_password::" }
            ]
        }
    ])
}

resource "aws_ecs_service" "std17_db" {
    name            = "std17-db-service"
    cluster         = var.cluster_name
    task_definition = aws_ecs_task_definition.std17_db.arn
    desired_count   = 1
    launch_type     = "EC2"

    service_registries {
        registry_arn = aws_service_discovery_service.mysql.arn
    }

    placement_constraints {
        type       = "memberOf"
        expression = "attribute:role == db"
    }
}