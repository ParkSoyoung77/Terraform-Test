resource "aws_db_subnet_group" "std17_mysql_subnet_group" {
  name       = "std17-mysql-subnet-group"
  subnet_ids = aws_subnet.std17_public_subnets[*].id

  tags = { Name = "std17-mysql-subnet-group" }
}

resource "aws_db_instance" "std17_mysql_rds" {
  identifier     = "std17-mysql-rds"
  engine         = "mysql"
  engine_version = "8.4.9"

  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  multi_az            = false
  availability_zone   = "ap-southeast-1a"

  db_subnet_group_name   = aws_db_subnet_group.std17_mysql_subnet_group.name
  vpc_security_group_ids = [aws_security_group.std17_test_sg.id]

  username = "admin"
  password = "12341234"

  publicly_accessible = true

  skip_final_snapshot = true

  tags = { Name = "std17-mysql-rds" }
}