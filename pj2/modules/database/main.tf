resource "aws_db_subnet_group" "std17_mysql_private_subnet_group" {
  name       = "std17-mysql-private-subnet-group"
  subnet_ids = var.db_private_subnet_ids

  tags = { Name = "std17-mysql-private-subnet-group" }
}

resource "aws_db_instance" "std17_mysql_rds" {
  identifier     = "std17-mysql-rds"
  engine         = "mysql"
  engine_version = var.engine_version

  instance_class    = var.instance_class
  allocated_storage = 20
  storage_type      = "gp2"

  db_name = var.db_name

  multi_az = var.multi_az

  db_subnet_group_name   = aws_db_subnet_group.std17_mysql_private_subnet_group.name
  vpc_security_group_ids = [var.security_group_id]

  username                     = "admin"
  manage_master_user_password  = true   # Secrets Manager가 비밀번호 자동 생성/관리

  publicly_accessible = false

  backup_retention_period = 7

  skip_final_snapshot = true

  tags = { Name = "std17-mysql-rds" }
}