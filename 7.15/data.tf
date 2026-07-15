data "aws_availability_zones" "az" {
    state = "available"
}

data "aws_secretsmanager_secret_version" "mysql_master" {
  secret_id = aws_secretsmanager_secret.mysql_master.id
}