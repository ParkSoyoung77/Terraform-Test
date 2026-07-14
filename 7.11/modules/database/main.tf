resource "aws_db_subnet_group" "std17_db_private_subnet_group" {
  name       = "std17-db-private-subnet-group"
  subnet_ids = var.private_subnet_ids

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

  db_subnet_group_name   = aws_db_subnet_group.std17_db_private_subnet_group.name
  vpc_security_group_ids = [var.security_group_id]

  username = var.db_username
  password = var.db_password

  publicly_accessible = false

  backup_retention_period = 7 # 0이 아닌 값 필수 (Read Replica 조건)

  skip_final_snapshot = true

  tags = { Name = "std17-mysql-rds" }
}

# resource "aws_db_instance" "std17_mysql_replica" {
#   identifier          = "std17-mysql-read-1"
#   replicate_source_db = aws_db_instance.std17_mysql_rds.identifier

#   instance_class = var.instance_class

#   publicly_accessible = false

#   skip_final_snapshot = true

#   tags = { Name = "std17-mysql-read-1" }
# }

# resource "aws_db_instance" "std17_mysql_replica_2" {
#   identifier          = "std17-mysql-read-2"
#   replicate_source_db = aws_db_instance.std17_mysql_rds.identifier

#   instance_class = var.instance_class

#   publicly_accessible = false

#   skip_final_snapshot = true

#   tags = { Name = "std17-mysql-read-2" }
# }
