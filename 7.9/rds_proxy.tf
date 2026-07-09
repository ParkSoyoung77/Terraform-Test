# ── RDS Proxy용 Secrets Manager 시크릿 ──────────────────
resource "aws_secretsmanager_secret" "std17_rds_proxy_secret" {
  name = "std17-rds-proxy-secret"
}

resource "aws_secretsmanager_secret_version" "std17_rds_proxy_secret_version" {
  secret_id = aws_secretsmanager_secret.std17_rds_proxy_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = "12341234"   # 실제로는 var.db_password 등으로 분리 권장
  })
}

# ── RDS Proxy가 Secrets Manager를 읽을 수 있는 IAM 역할 ────
resource "aws_iam_role" "std17_rds_proxy_role" {
  name = "std17-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "std17_rds_proxy_policy" {
  name = "std17-rds-proxy-policy"
  role = aws_iam_role.std17_rds_proxy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = aws_secretsmanager_secret.std17_rds_proxy_secret.arn
    }]
  })
}

# ── RDS Proxy ───────────────────────────────────────────
resource "aws_db_proxy" "std17_rds_proxy" {
  name                   = "std17-rds-proxy"
  engine_family          = "MYSQL"
  role_arn               = aws_iam_role.std17_rds_proxy_role.arn
  vpc_subnet_ids         = aws_subnet.std17_private_subnets[*].id
  vpc_security_group_ids = [aws_security_group.std17_test_sg.id]

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.std17_rds_proxy_secret.arn
    iam_auth    = "DISABLED"
  }

  require_tls = false

  tags = { Name = "std17-rds-proxy" }
}

# ── Proxy → 실제 RDS(Primary) 연결하는 Target Group ─────────
resource "aws_db_proxy_default_target_group" "std17_rds_proxy_tg" {
  db_proxy_name = aws_db_proxy.std17_rds_proxy.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "std17_rds_proxy_target" {
  db_proxy_name          = aws_db_proxy.std17_rds_proxy.name
  target_group_name      = aws_db_proxy_default_target_group.std17_rds_proxy_tg.name
  db_instance_identifier = aws_db_instance.std17_mysql_rds.identifier
}