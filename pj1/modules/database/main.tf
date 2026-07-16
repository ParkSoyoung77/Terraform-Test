resource "aws_db_subnet_group" "std17_db_private_subnet_group" {
  name       = "std17-db-private-subnet-group"
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

  multi_az = true
  db_name  = "studydb"

  db_subnet_group_name   = aws_db_subnet_group.std17_db_private_subnet_group.name
  vpc_security_group_ids = [var.security_group_id]

  username = jsondecode(data.aws_secretsmanager_secret_version.mysql_master.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.mysql_master.secret_string)["password"]

  publicly_accessible = false

  backup_retention_period = 7

  skip_final_snapshot = true

  tags = { Name = "std17-mysql-rds" }
}
