output "mysql_credentials_secret_arn" {
    value = aws_secretsmanager_secret.mysql_credentials.arn
}