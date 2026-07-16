data "aws_secretsmanager_secret_version" "mysql_master" {
  secret_id = var.db_secret_arn
}