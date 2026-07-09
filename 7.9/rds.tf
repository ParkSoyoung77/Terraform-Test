resource "aws_db_subnet_group" "std17_mysql_private_subnet_group" {
  name       = "std17-mysql-private-subnet-group"
  subnet_ids = aws_subnet.std17_private_subnets[*].id

  tags = { Name = "std17-mysql-private-subnet-group" }
}

resource "aws_db_instance" "std17_mysql_rds" {
  identifier     = "std17-mysql-rds"
  engine         = "mysql"
  engine_version = "8.4.9"

  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  multi_az            = true

  db_subnet_group_name   = aws_db_subnet_group.std17_mysql_private_subnet_group.name
  vpc_security_group_ids = [aws_security_group.std17_test_sg.id]

  username = "admin"
  password = "12341234"

  publicly_accessible = false

  backup_retention_period = 7   # 0이 아닌 값 필수 (Read Replica 조건)
  
  skip_final_snapshot = true

  tags = { Name = "std17-mysql-rds" }
}

resource "aws_db_instance" "std17_mysql_replica" {
  identifier = "std17-mysql-replica-1"
  replicate_source_db = aws_db_instance.std17_mysql_rds.identifier
                                     
  instance_class = "db.t4g.micro"

  publicly_accessible = true

  skip_final_snapshot = true

  tags = { Name = "std17-mysql-replica-1"}
}

resource "aws_db_instance" "std17_mysql_replica_2" {
  identifier = "std17-mysql-replica-2"
  replicate_source_db = aws_db_instance.std17_mysql_rds.identifier
                                     
  instance_class = "db.t4g.micro"

  publicly_accessible = false

  skip_final_snapshot = true

  tags = { Name = "std17-mysql-replica-2"}
}

resource "aws_db_instance" "std17_mysql_replica_3" {
  identifier = "std17-mysql-replica-3"
  replicate_source_db = aws_db_instance.std17_mysql_rds.identifier
                                     
  instance_class = "db.t4g.micro"

  publicly_accessible = true

  skip_final_snapshot = true

  tags = { Name = "std17-mysql-replica-3"}
}