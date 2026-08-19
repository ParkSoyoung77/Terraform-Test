resource "random_password" "mysql_root" {
    length  = 20
    special = false
}

resource "random_password" "mysql_app" {
    length  = 20
    special = false
}

resource "aws_secretsmanager_secret" "mysql_credentials" {
    name = "std17-mysql-credentials"
}

resource "aws_secretsmanager_secret_version" "mysql_credentials" {
    secret_id = aws_secretsmanager_secret.mysql_credentials.id
    secret_string = jsonencode({
        root_password = random_password.mysql_root.result
        app_username  = "std17"
        app_password  = random_password.mysql_app.result
        database      = var.db_name
        host          = "mysql.std17.local"
        port          = "3306"
    })
}