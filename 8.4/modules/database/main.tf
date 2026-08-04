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
  storage_type      = "gp3"

  db_name = var.db_name

  multi_az           = var.multi_az   # true → Standby 자동 생성 (Writer와 다른 AZ에 자동 배치)

  db_subnet_group_name   = aws_db_subnet_group.std17_db_private_subnet_group.name
  vpc_security_group_ids = [var.security_group_id]

  username = "admin"
  password = random_password.std17_db_password.result

  publicly_accessible = false

  backup_retention_period = 7   # Read Replica 조건: 0이면 안 됨

  skip_final_snapshot = true

  tags = { Name = "std17-mysql-rds" }
}

# ---------------------------------------------------------
# Random Password
# ---------------------------------------------------------
resource "random_password" "std17_db_password" {
  length  = 20
  special = false   # RDS 비밀번호에 못 쓰는 특수문자(/,@,",공백) 회피
}

resource "aws_secretsmanager_secret" "std17_db_secret" {
  name = "std17-mysql-rds-secret"
  description = "std17-mysql-rds master credentials"
  recovery_window_in_days = 0

  tags = { Name = "std17-mysql-rds-secret" }
}

resource "aws_secretsmanager_secret_version" "std17_db_secret_version" {
  secret_id = aws_secretsmanager_secret.std17_db_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.std17_db_password.result
    apply_immediately   = true
  })
}