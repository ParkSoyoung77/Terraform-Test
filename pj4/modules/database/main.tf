resource "aws_db_subnet_group" "std17_db_private_subnet_group" {
  name       = "std17-mysql-private-subnet-group"
  subnet_ids = var.db_private_subnet_ids

  tags = { Name = "std17-db-private-subnet-group" }
}

resource "aws_db_instance" "std17_mysql_rds" {
  identifier     = "std17-mysql-rds"
  engine         = "mysql"
  engine_version = var.engine_version

  instance_class    = var.instance_class
  allocated_storage = 20
  storage_type      = "gp2"

  db_name = var.db_name

  multi_az           = var.multi_az   # true → Standby 자동 생성 (Writer와 다른 AZ에 자동 배치)

  db_subnet_group_name   = aws_db_subnet_group.std17_db_private_subnet_group.name
  vpc_security_group_ids = [var.security_group_id]

  username                    = "admin"
  manage_master_user_password = true   # Secrets Manager가 비밀번호 자동 생성/관리

  publicly_accessible = false

  backup_retention_period = 7   # Read Replica 조건: 0이면 안 됨

  skip_final_snapshot = true

  tags = { Name = "std17-mysql-rds" }
}

# ---------------------------------------------------------
# Read only
# --------------------------------------------------------

resource "aws_db_instance" "std17_mysql_replica" {
  identifier          = "std17-mysql-read-1"
  replicate_source_db = aws_db_instance.std17_mysql_rds.arn

  instance_class     = var.instance_class
  availability_zone  = "us-west-1c"   # Replica 고정

  db_subnet_group_name   = aws_db_subnet_group.std17_db_private_subnet_group.name
  vpc_security_group_ids = [var.security_group_id]

  publicly_accessible = false
  skip_final_snapshot = true

  tags = { Name = "std17-mysql-read-1" }
}

# ---------------------------------------------------------
# RDS Proxy
# ---------------------------------------------------------
resource "aws_db_proxy" "std17_rds_proxy" {
  name                   = "std17-rds-proxy"
  engine_family           = "MYSQL"
  role_arn                = var.rds_proxy_role_arn   # iam 모듈에서 전달받음
  vpc_subnet_ids           = var.db_private_subnet_ids
  vpc_security_group_ids   = [var.security_group_id]

  require_tls = false

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_db_instance.std17_mysql_rds.master_user_secret[0].secret_arn
    iam_auth    = "DISABLED"
  }

  tags = { Name = "std17-rds-proxy" }
}

resource "aws_db_proxy_default_target_group" "std17_rds_proxy_target_group" {
  db_proxy_name = aws_db_proxy.std17_rds_proxy.name

  connection_pool_config {
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "std17_rds_proxy_target" {
  db_proxy_name          = aws_db_proxy.std17_rds_proxy.name
  target_group_name       = aws_db_proxy_default_target_group.std17_rds_proxy_target_group.name
  db_instance_identifier   = aws_db_instance.std17_mysql_rds.identifier
}

# RDS Proxy 역할에 "이 DB의 시크릿을 읽어라" 정책 부착 (순환참조 방지: 여기서 부착)
resource "aws_iam_role_policy" "std17_rds_proxy_secrets_policy" {
  name = "std17-rds-proxy-secrets-policy"
  role = var.rds_proxy_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [aws_db_instance.std17_mysql_rds.master_user_secret[0].secret_arn]
    }]
  })
}